from __future__ import annotations

try:
    from gitlab_arc_fs.arc_fs import ARCfs
except ImportError:
    ARCfs = None

from typing import (
    Optional,
    Union,
)

from galaxy.files.models import (
    BaseFileSourceConfiguration,
    BaseFileSourceTemplateConfiguration,
    FilesSourceRuntimeContext,
)
from galaxy.util.config_templates import TemplateExpansion
from ._pyfilesystem2 import PyFilesystem2FilesSource


class ARCfsTemplateConfiguration(BaseFileSourceTemplateConfiguration):
    token: Optional[Union[str, TemplateExpansion]] = None
    server_url: Union[str, TemplateExpansion]


class ARCfsResolvedConfiguration(BaseFileSourceConfiguration):
    token: Optional[str] = None
    server_url: str


class ARCfsFilesSource(PyFilesystem2FilesSource[ARCfsTemplateConfiguration, ARCfsResolvedConfiguration]):
    plugin_type = "arcfs"
    required_module = ARCfs
    required_package = "gitlab_arc_fs"
    template_config_class = ARCfsTemplateConfiguration
    resolved_config_class = ARCfsResolvedConfiguration

    def _open_fs(self, context: FilesSourceRuntimeContext[ARCfsResolvedConfiguration]):
        if ARCfs is None:
            raise self.required_package_exception

        cfg = context.config

        token = (cfg.token or "").strip()

        server_url = (cfg.server_url or "").strip().rstrip("/")
        if not server_url:
            raise ValueError("server_url must be configured for ARCfs")

        return ARCfs(token=token, server_url=server_url)


__all__ = ("ARCfsFilesSource",)
