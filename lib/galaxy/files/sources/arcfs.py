try:
    from gitlab_arc_fs.arc_fs import ARCfs
except ImportError:
    ARCfs = None
from ._pyfilesystem2 import PyFilesystem2FilesSource  # NOQA


class ARCfsFilesSource(PyFilesystem2FilesSource):
    plugin_type = "arcfs"
    required_module = ARCfs
    required_package = "gitlab_arc_fs"

    def _open_fs(self, user_context, opts = None):  # NOQA
        props = self._serialization_props(user_context)
        handle = ARCfs(**props)
        return handle


__all__ = (ARCfsFilesSource,)
