try:
    from gitlab_arc_fs.gitlab_fs import GitlabFS
except ImportError:
    GitlabFS = None
from ._pyfilesystem2 import PyFilesystem2FilesSource  # NOQA


class GitlabFSFilesSource(PyFilesystem2FilesSource):
    plugin_type = "gitlabfs"
    required_module = GitlabFS
    required_package = "gitlab_fs"

    def _open_fs(self, user_context):
        props = self._serialization_props(user_context)
        handle = GitlabFS(**props)
        return handle


__all__ = (GitlabFSFilesSource,)
