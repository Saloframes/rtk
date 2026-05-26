# Google Antigravity Hooks

> Part of [`hooks/`](../README.md) — see also [`src/hooks/`](../../src/hooks/README.md) for installation code

## Supported Modes

RTK supports two separate Google Antigravity integrations:

### 1. Antigravity CLI (`agy`) — Programmatic Hook

The `agy` CLI (successor to Gemini CLI) supports a JSON hook protocol.  RTK registers as a `PreToolUse` hook that rewrites shell commands before execution.

**Install (global only):**
```bash
rtk init -g --agent agy
```

agy CLI hook support is **global-only** — there is no project-local install. The hook runner is registered system-wide so it intercepts all agy sessions.

**Files written:**
- `~/.gemini/config/hooks.json` — registers the `PreToolUse` hook
- `~/.gemini/antigravity-cli/settings.json` — grants `command(rtk)` permission

**Hook entry written to `~/.gemini/config/hooks.json`:**
```json
{
  "rtk-antigravity": {
    "enabled": true,
    "PreToolUse": [
      {
        "toolNameMatcher": "^(run_command|Bash|bash)$",
        "hooks": [{"type": "command", "command": "/path/to/rtk hook antigravity"}]
      }
    ]
  }
}
```

**Hook protocol:**

agy sends a JSON payload to stdin; the hook replies to stdout.

Input (`run_command` tool):
```json
{"toolCall": {"name": "run_command", "args": {"CommandLine": "git status"}}}
```

Output — deny with replacement name (model retries with `rtk git status`, auto-approved via `command(rtk)` allow entry):
```json
{"denyReason": "RTK: use 'rtk git status' instead of 'git status' (60-90% token savings)"}
```

Input (`Bash` tool):
```json
{"toolCall": {"name": "Bash", "args": {"command": "cargo test"}}}
```

Non-shell tools and commands already prefixed with `rtk` receive `{"allowTool": true}` and pass through unchanged.

> **Note:** agy's `overwrite` field in `PreToolHookResult` is silently ignored regardless of `toolPermission` mode. RTK uses the deny-and-retry pattern as a workaround until `overwrite` is implemented by agy.

**Uninstall:**
```bash
rtk init -g --uninstall --agent agy
```

### 2. Antigravity IDE — Prompt-Level Guidance

The Antigravity IDE (formerly "Antigravity") reads project rules files.  RTK installs its awareness instructions as a rules file.

**Install (project-local only):**
```bash
rtk init --agent antigravity
```

- Installs `.agents/rules/antigravity-rtk-rules.md` in the project root
- Instructs Antigravity to prefix shell commands with `rtk`
- No programmatic hook — relies on the model following the rules

## Gemini CLI (Legacy)

The Gemini CLI is still supported but is now considered **legacy**.  New users should use `agy`.

```bash
rtk init -g --gemini    # Gemini CLI (legacy)
```
