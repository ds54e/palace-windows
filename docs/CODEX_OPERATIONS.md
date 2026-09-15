# Cost-controlled Codex operation

## Default

Use Terra / medium as the single parent and sole writer. This is this project's cost-first choice, not a measured claim that Terra will outperform other models on this port. `.codex/config.toml` contains only the parent model and reasoning default. No approvals, authentication, global configuration, or account settings are changed by the repository.

Before the first substantive task, record the installed CLI version and inspect `/model` and `/status`. Confirm the effective model/effort, account access, and premium speed status. Do not infer local availability solely from a web model list. Do not silently substitute a more expensive model.

## Delegation envelope

| Role | Setting | Allowed work | Initial envelope |
| --- | --- | --- | --- |
| Parent | Terra / medium | Implementation, commands, integration, tests | Normal work |
| Log reader | Luna / medium | Bounded log extraction or factual file survey | At most 2 launches per gate |
| Specialist | Sol / high | Isolated ABI, loader, build, or numerical diagnosis | At most 1 launch per blocker and 3 in total before owner review |
| Astra | Not configured | Exceptional only | No authorization in the default policy |

At most one child can be active, and children must not spawn other children. Launch counts persist in `docs/STATE.json`; a new chat does not reset them. The limits are project policy, not guaranteed billing enforcement. They are intentionally not quotas that must be consumed.

Use shell tools for filtering a log or hashing files before paying a model to do it. Luna is optional, not a mandatory hop. After at most two distinct evidence-producing parent experiments fail to discriminate a difficult blocker, a Sol consultation is authorized within the envelope. Do not retry identical builds or resubmit the same evidence.

The parent chooses the next experiment, applies patches, and validates. Children are read-only investigators; do not ask them to install tools, build in a shared directory, edit sources, or approve publication. One heavyweight build runs at a time.

## What model selection means here

The user controls the running parent with `/model` or launch options. Repository instructions do not magically change that parent. Current official documentation supports separate model/effort settings for child agents, defaults, and project custom-agent files; see `docs/SOURCES.md`. The installed CLI still needs verification.

Optional current-schema files are kept under `config/codex/`, outside the auto-loaded directory. Once local support is confirmed, merge the small multi-agent fragment into `.codex/config.toml` and copy the two role files to `.codex/agents/`. Record the change and its test. Verify a child's actual selected model from the client/tool metadata, not the child's self-description. If selection cannot be verified, continue parent-only.

The generic child default is Luna. The specialist's role explicitly pins Sol and high effort; do not use a generic child without checking which model was selected. Never depend on undocumented `fork_turns` values. Give a bounded task packet using whatever context mode the installed CLI supports. Do not replay the entire project history into a specialist.

Do not use nested `codex exec`, self-edit global configs, restart yourself under a different account, or build an automatic routing service as a workaround. A routing failure must not become the Palace project's new main task.

## Bounded task packet

Provide: blocker ID and gate; one question; source commit; toolchain/ABI summary; exact failing command; short error excerpt and local log path; up to a small set of relevant files; experiments already tried and their outcomes; constraints; requested return format.

Ask for a concise diagnosis: supported facts, ranked hypotheses, one discriminating test, minimal patch suggestion, uncertainty. A practical soft cap is about 4,000 input tokens and 800 output tokens; it is not a technical token limiter. Do not omit essential evidence merely to meet the cap.

Record requested/observed model and effort, launch count, result, and next action. Token/credit data may be recorded only when exposed by the client; unavailable usage remains unknown. No invented per-project cost or allocation percentages.

## Session continuity and exhaustion

Checkpoint after a meaningful gate result or before context compaction. Resume from `STATE.json`, relevant decisions, and the latest bounded log summary instead of rereading all documents/logs. Preserve raw logs locally and sanitize evidence committed to Git.

If model access or quota is exhausted, leave a resumable blocker. Do not buy credits, change billing/sign-in method, or launch more expensive agents. Continue independent parent work when possible. A stronger model is a diagnostic resource, not an excuse to lower release tests.
