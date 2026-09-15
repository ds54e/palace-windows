# Verification sources

Checked on 2026-09-16. These are investigation entry points, not a claim that the local host or any binary was tested. Re-check version-specific behavior against the pinned source and the actual CLI.

| Topic | Primary source | Use |
| --- | --- | --- |
| Codex model IDs and selection | https://learn.chatgpt.com/docs/models | Confirm available CLI model names; local account still controls access |
| Child models/custom agents | https://learn.chatgpt.com/docs/agent-configuration/subagents | Current custom-agent configuration and delegation behavior |
| Configuration fields | https://learn.chatgpt.com/docs/config-file/config-reference | Optional child defaults and concurrency key |
| Model switch/status | https://learn.chatgpt.com/docs/developer-commands?surface=cli | User-controlled selection and effective-status check |
| Palace release | https://github.com/awslabs/palace/releases/tag/v0.18.0 | Starting release, not a claim of Windows support |
| Palace source | https://github.com/awslabs/palace/tree/b92aef83ecfe6d360c4b3d83e2122986297f6778 | Fixed input to portability work |
| Palace build options | https://awslabs.github.io/palace/stable/install/ | Dependency candidates and build switches |
| WSL interoperability | https://learn.microsoft.com/en-us/windows/wsl/filesystems | Windows executable invocation and path semantics |
| Microsoft MPI | https://github.com/microsoft/Microsoft-MPI | Runtime source/build investigation, not app-local certification |
| Prior Windows port | https://github.com/WelSimLLC/WelSim-Apps/discussions/145 | Prior-art lead; diff and reproduce rather than assume compatibility |

The model policy, launch envelope, gates, and acceptance criteria in this repository are project decisions. No price table, version-specific fork parameter, or guaranteed cost ratio is hardcoded. Older conversation assertions are not evidence.
