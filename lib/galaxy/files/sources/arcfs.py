from __future__ import annotations

try:
    from gitlab_arc_fs.arc_fs import ARCfs
except ImportError:
    ARCfs = None

from ._pyfilesystem2 import PyFilesystem2FilesSource

from galaxy.files.models import (  # type: ignore
    BaseFileSourceConfiguration,
    BaseFileSourceTemplateConfiguration,
    FilesSourceRuntimeContext,
)
from galaxy.util.config_templates import TemplateExpansion  # type: ignore

from typing import Union


class ARCfsTemplateConfiguration(BaseFileSourceTemplateConfiguration):
    token: Union[str, TemplateExpansion] = ""
    server_url: Union[str, TemplateExpansion] = ""


class ARCfsResolvedConfiguration(BaseFileSourceConfiguration):
    token: str = ""
    server_url: str = ""


class ARCfsFilesSource(PyFilesystem2FilesSource[ARCfsTemplateConfiguration, ARCfsResolvedConfiguration]):
    plugin_type = "arcfs"
    required_module = ARCfs
    required_package = "gitlab_arc_fs"

    template_config_class = ARCfsTemplateConfiguration
    resolved_config_class = ARCfsResolvedConfiguration

    def _open_fs(self, context: FilesSourceRuntimeContext[ARCfsResolvedConfiguration], **kwargs):
        cfg = context.config
        token = (cfg.token or "").strip()
        server_url = (cfg.server_url or "").strip().rstrip("/")
        return ARCfs(token=token, server_url=server_url)


__all__ = ("ARCfsFilesSource",)
