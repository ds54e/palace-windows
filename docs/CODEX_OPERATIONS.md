# Cost-controlled Codex operation

## Default parent

Use **Astra / low** as the normal parent and sole writer for the V1 effort. This is the owner's current choice for long-horizon implementation quality; it is not a claim that Astra is always cheaper or better on every task. `.codex/config.toml` contains only the parent model and reasoning default. No approvals, authentication, global configuration, billing settings, or account settings are changed by the repository.

Before the first substantive task in a fresh environment, record the installed CLI version and inspect `/model` and `/status`. Confirm the effective model/effort, account access, and premium speed status. Do not infer local availability solely from documentation or a web model list. Do not silently substitute a different model.

## Fallback and delegation

| Role | Setting | Allowed work | Policy |
| --- | --- | --- | --- |
| Parent default | Astra / low | Implementation, commands, integration, tests, long-horizon execution | Normal V1 work |
| Parent fallback | Sol / medium | Same parent responsibilities when Astra is too costly, quota-constrained, unavailable, or clearly poor value for a sustained phase | User-controlled switch only |
| Log reader | Luna / medium | Bounded log extraction or factual file survey | At most 2 launches per gate |
| Higher Astra effort | Not configured | Exceptional difficult blocker only | Requires explicit owner authorization |
| Terra | Not configured | No default V1 role | Use only if the owner later chooses it |

The parent model is not switched autonomously by repository instructions. If a fallback is warranted, checkpoint state and tell the owner exactly why; the owner may use `/model`, launch options, or edit project config. A fallback recommendation should cite observable evidence such as quota pressure, client-exposed usage, repeated low-value long outputs, or materially better fit for a routine phase. Do not invent token or credit data.

At most one child can be active, and children must not spawn other children. Luna launch counts persist in `docs/STATE.json`; a new chat does not reset them. These are project policies, not guaranteed billing enforcement, and they are not quotas that must be consumed.

Use shell tools for filtering logs, hashing files, or extracting deterministic facts before paying a model to do it. Luna is optional, not a mandatory hop. The parent remains responsible for choosing the next experiment, applying patches, building, and validation. Children are read-only investigators; do not ask them to install tools, build in a shared directory, edit sources, or approve publication. One heavyweight build runs at a time.

## Difficult blockers

Astra/low should first produce evidence: a minimal reproducer, bounded logs, exact commands, diffs, or a narrowed hypothesis set. Do not raise reasoning effort merely because the first attempt failed.

For a difficult blocker:

1. Run at most two distinct evidence-producing experiments that can discriminate hypotheses.
2. Reduce the problem to the smallest useful evidence packet.
3. Continue on Astra/low if the next experiment is clear.
4. If the problem remains genuinely ambiguous, checkpoint it and request owner authorization before using higher Astra effort.
5. Sol/medium is a cost fallback parent, not an automatic escalation to a stronger reviewer.

Do not repeatedly retry the same build or resubmit the same evidence. Do not create an automatic model-routing service; routing must not become the Palace project's main task.

## What model selection means here

The user controls the running parent with `/model`, launch options, or an explicit project config change. Repository instructions do not magically replace the already-running parent. Current Codex schemas may support child-agent model/effort settings, but the installed CLI still needs verification.

The optional multi-agent fragment under `config/codex/` keeps Luna as the generic child. Activate it only after confirming the local CLI schema and observing the actual selected child model from client/tool metadata rather than the child's self-description. If selection cannot be verified, continue parent-only.

Do not use nested `codex exec`, self-edit global configs, restart yourself under another account, or alter billing/authentication as a workaround.

## Bounded Luna task packet

Provide: gate/blocker ID; one factual question; source commit; relevant command or short log excerpt; a small set of files; requested return format. Ask for concrete facts, file/line references, and uncertainty. A practical soft cap is about 4,000 input tokens and 800 output tokens; it is not a technical token limiter. Do not omit essential evidence merely to meet the cap.

Record requested/observed model and effort, launch count, result, and next action. Token/credit data may be recorded only when exposed by the client; unavailable usage remains unknown.

## Sol fallback procedure

A Sol/medium fallback is intended to reduce sustained Astra consumption, not to create parallel implementation tracks.

Before switching:

- checkpoint `docs/STATE.json` and `docs/DEVLOG.md`;
- record the reason for the switch;
- keep the same one-writer rule;
- do not lower release criteria or numerical validation;
- prefer completing the current coherent gate before switching back again.

A convenience snippet is kept at `config/codex/sol-fallback.toml`. Applying it is an owner/user action, not an autonomous agent action.

## Session continuity and exhaustion

Checkpoint after a meaningful gate result or before context compaction. Resume from `STATE.json`, relevant decisions, and the latest bounded log summary instead of rereading all documents/logs. Preserve raw logs locally and sanitize evidence committed to Git.

If model access or quota is exhausted, leave a resumable blocker. Do not buy credits, change billing/sign-in method, or silently raise model effort. Continue independent work when possible. Model choice never justifies lowering release tests.
