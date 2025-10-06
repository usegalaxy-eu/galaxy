import os
from datetime import datetime
from typing import (
    cast,
    List,
    Optional,
    Tuple,
    Unpack,
)

from omero.gateway import BlitzGateway

from galaxy.files import OptionalUserContext
from galaxy.files.sources import (
    AnyRemoteEntry,
    BaseFilesSource,
    FilesSourceOptions,
    FilesSourceProperties,
    PluginKind,
)


class OmeroFilesSourceProperties(FilesSourceProperties):
    username: str
    password: str
    host: str
    port: int


class OmeroFileSource(BaseFilesSource):
    plugin_type = "omero"
    plugin_kind = PluginKind.rfs

    def __init__(self, **kwd: Unpack[OmeroFilesSourceProperties]):
        props = self._parse_common_config_opts(kwd)
        self._props = cast(OmeroFilesSourceProperties, props)

    def _open_connection(self) -> BlitzGateway:
        return BlitzGateway(
            self._props.get("username"),
            self._props.get("password"),
            host=self._props.get("host"),
            port=self._props.get("port"),
            secure=True,
        )

    def _list(
        self,
        path="/",
        recursive=False,
        user_context: OptionalUserContext = None,
        opts: Optional[FilesSourceOptions] = None,
        limit: Optional[int] = None,
        offset: Optional[int] = None,
        query: Optional[str] = None,
        sort_by: Optional[str] = None,
    ) -> Tuple[List[AnyRemoteEntry], int]:
        """
        List OMERO objects in a hierarchical structure:
        - Projects as directories at root level
        - Datasets as directories within projects
        - Images as files within datasets

        Path format:
        - "/" or "" - lists all projects
        - "/project_<id>" - lists datasets in a project
        - "/project_<id>/dataset_<id>" - lists images in a dataset
        """
        omero = self._open_connection()
        if not omero.connect():
            raise Exception("Could not connect to OMERO server")

        try:
            results: List[AnyRemoteEntry] = []

            # Parse the path
            path = path.strip("/")
            path_parts = [p for p in path.split("/") if p]

            if len(path_parts) == 0:
                # Root level - list all projects
                for project in omero.getObjects("Project"):
                    project_path = f"project_{project.getId()}"
                    results.append(
                        {
                            "class": "Directory",
                            "name": project.getName() or f"Project {project.getId()}",
                            "uri": self.uri_from_path(project_path),
                            "path": project_path,
                        }
                    )

            elif len(path_parts) == 1:
                # Project level - list datasets in the project
                project_id_str = path_parts[0]
                if project_id_str.startswith("project_"):
                    project_id = int(project_id_str.replace("project_", ""))
                    project = omero.getObject("Project", project_id)
                    if project:
                        for dataset in project.listChildren():
                            dataset_path = f"{project_id_str}/dataset_{dataset.getId()}"
                            results.append(
                                {
                                    "class": "Directory",
                                    "name": dataset.getName() or f"Dataset {dataset.getId()}",
                                    "uri": self.uri_from_path(dataset_path),
                                    "path": dataset_path,
                                }
                            )

            elif len(path_parts) == 2:
                # Dataset level - list images in the dataset
                project_id_str = path_parts[0]
                dataset_id_str = path_parts[1]
                if dataset_id_str.startswith("dataset_"):
                    dataset_id = int(dataset_id_str.replace("dataset_", ""))
                    dataset = omero.getObject("Dataset", dataset_id)
                    if dataset:
                        for image in dataset.listChildren():
                            image_path = f"{project_id_str}/{dataset_id_str}/image_{image.getId()}"
                            # Get image creation time
                            ctime = image.getDate()
                            if ctime:
                                ctime_str = ctime.isoformat()
                            else:
                                ctime_str = datetime.now().isoformat()

                            # Calculate approximate size (this is a rough estimate)
                            # OMERO doesn't easily provide file size, so we estimate from pixels
                            pixels = image.getPrimaryPixels()
                            size_x = pixels.getSizeX()
                            size_y = pixels.getSizeY()
                            size_z = pixels.getSizeZ()
                            size_c = pixels.getSizeC()
                            size_t = pixels.getSizeT()
                            pixel_type = pixels.getPixelsType().getValue()

                            # Estimate bytes per pixel based on pixel type
                            bytes_per_pixel = 1
                            if "int16" in pixel_type or "uint16" in pixel_type:
                                bytes_per_pixel = 2
                            elif "int32" in pixel_type or "uint32" in pixel_type or "float" in pixel_type:
                                bytes_per_pixel = 4
                            elif "double" in pixel_type:
                                bytes_per_pixel = 8

                            estimated_size = size_x * size_y * size_z * size_c * size_t * bytes_per_pixel

                            results.append(
                                {
                                    "class": "File",
                                    "name": f"{image.getName() or f'Image {image.getId()}'}",
                                    "size": estimated_size,
                                    "ctime": ctime_str,
                                    "uri": self.uri_from_path(image_path),
                                    "path": image_path,
                                }
                            )

            return results, len(results)

        finally:
            omero.close()

    def _realize_to(
        self,
        source_path: str,
        native_path: str,
        user_context: OptionalUserContext = None,
        opts: Optional[FilesSourceOptions] = None,
    ):
        """
        Download an OMERO image to a local file.

        This method attempts to download the original imported file to preserve
        the original format. If the original file is not available, it falls back
        to exporting pixel data.

        The source_path should be in format: project_<id>/dataset_<id>/image_<id>
        """
        omero = self._open_connection()
        if not omero.connect():
            raise Exception("Could not connect to OMERO server")

        try:
            # Parse the path to extract image ID
            path_parts = [p for p in source_path.strip("/").split("/") if p]

            if len(path_parts) != 3 or not path_parts[2].startswith("image_"):
                raise ValueError(
                    f"Invalid image path: {source_path}. Expected format: project_<id>/dataset_<id>/image_<id>"
                )

            image_id = int(path_parts[2].replace("image_", ""))
            image = omero.getObject("Image", image_id)

            if not image:
                raise Exception(f"Image with ID {image_id} not found")

            # Try to download the original imported file first
            original_file_downloaded = False

            # Check if the image has imported files (for OMERO 5.0+)
            file_count = image.countFilesetFiles()

            if file_count > 0:
                # Get the original imported files
                # Note: For multi-file formats, this gets the first file
                for orig_file in image.getImportedImageFiles():
                    # Download the original file in chunks
                    with open(native_path, "wb") as f:
                        for chunk in orig_file.getFileInChunks():
                            f.write(chunk)

                    original_file_downloaded = True
                    break  # Only download the first file

            # If original file download failed or not available, fall back to pixel export
            if not original_file_downloaded:
                # Get the primary pixels
                pixels = image.getPrimaryPixels()
                size_z = image.getSizeZ()
                size_c = image.getSizeC()
                size_t = image.getSizeT()

                try:
                    from PIL import Image as PILImage

                    # Export a single plane as TIFF
                    # For multi-dimensional images, export the middle Z-slice
                    z = size_z // 2 if size_z > 1 else 0
                    plane = pixels.getPlane(z, 0, 0)
                    img = PILImage.fromarray(plane)
                    img.save(native_path, format="TIFF")

                except Exception:
                    # Final fallback: get a rendered thumbnail
                    img_data = image.getThumbnail()
                    with open(native_path, "wb") as f:
                        f.write(img_data)

        finally:
            omero.close()

    def _write_from(
        self,
        target_path: str,
        native_path: str,
        user_context: OptionalUserContext = None,
        opts: Optional[FilesSourceOptions] = None,
    ):
        """
        Uploading to OMERO is not supported in this implementation.
        """
        raise NotImplementedError("Uploading files to OMERO is not supported.")

    def _serialization_props(self, user_context: OptionalUserContext = None):
        effective_props = {}
        for key, val in self._props.items():
            effective_props[key] = self._evaluate_prop(val, user_context=user_context)
        return effective_props


__all__ = ("OmeroFileSource",)
