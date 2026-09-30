# Sync Conflict Resolution — 2026-09-30

Branch: `sync/upstream-2026-09-30`  
Merge: `upstream/develop` → fork  
Policy: **upstream wins**; only genuinely additive fork code survives.

---

## Conflicted Files — Resolution Summary

### `docs/guide/getting-started/supported-agents.md` (UU)
- **Kept upstream**: Antigravity description gained `rules/AGENTS.md` awareness file entry; removed `(<1.5ms overhead)` timing claim. Agent ordering in integration tiers text updated (Factory Droid before Antigravity).

### `hooks/README.md` (UU)
- **Kept upstream**: Trae listed before Google Antigravity in 13-agent count.

### `hooks/antigravity/README.md` (UU)
- **Kept upstream**: Removed `(<1.5ms)` timing claim; added awareness file line.

### `hooks/claude/rtk-rewrite.sh` (UU)
- Fork had `rtk rewrite -- "$CMD"` (`--` terminator, issue #1350 fix).
- **Kept upstream**: `env -u RTK_REWRITE_HOST rtk rewrite "$CMD"` (host-scrubbing approach).

### `hooks/cursor/rtk-rewrite.sh` (UU)
- Same pattern as claude hook.
- **Kept upstream**: `env -u RTK_REWRITE_HOST` version.

### `hooks/pi/rtk.ts` (auto-merged, reverted)
- Auto-merge kept fork's `--` terminator addition (issue #1350).
- **Reverted to upstream** via `git checkout upstream/develop -- hooks/pi/rtk.ts`.
- Fork's historical hashes (carrying `--` terminator) added to `KNOWN_PI_PLUGIN_HASHES` in `src/hooks/init/pi.rs` so the allowlist test covers fork git history:
  - `8a496cff6486565ad4b90b4770f124f6f5fb470b44c95ea9911c2314c136bbe1`
  - `dfe5632df8141ad0f757c9c3084b16ffbe7810125692492bd4f1806ead457ca2`
  - `46f413895909c91c44c8cac7d02ab922369512c019cfac69f13c4d6410751854`

### `src/core/runner.rs` (UU) — ADDITIVE MERGE
- **Kept upstream additions**: `MAX_FORWARDED_STDERR_LINES`, `forwarded_stderr()`, `last_lines_offset()` (stderr capping for `run_captured_filter`).
- **Kept fork additions** (additive — not in upstream): `DASH_H_IS_NOT_HELP`, `pub fn requests_help()` (help-passthrough for wrapped tools).
- Both sets of functions needed: `forwarded_stderr` called from upstream code; `requests_help` called from fork's `src/main.rs` and `src/hooks/rewrite_cmd.rs`.

### `src/discover/rules.rs` (UU)
- **Kept upstream**: yadm added to git rule pattern (`^(?:git|yadm)\s+...`).
- **Fork addition preserved**: `"yadm"` added to `rewrite_prefixes` so `rewrite_command_no_prefixes("yadm status")` returns `Some("rtk git status")` (required by registry tests).

### `src/hooks/README.md` (UU)
- **Kept upstream**: Antigravity row updated with `rules/AGENTS.md (awareness)` in patches column; OpenClaw row added to per-tool support table.

### `src/hooks/hook_cmd.rs` (UU)
- **Kept upstream**: Three new Antigravity tests added (`test_antigravity_pre_prefixed_command_defers`, `test_antigravity_shell_redirection_and_subshells_defer`, `test_antigravity_unknown_binary_passthrough`).

### `src/hooks/init.rs` (UD — fork modified, upstream deleted)
- Upstream refactored monolithic `init.rs` into `src/hooks/init/` submodule tree.
- **Decision**: Accepted deletion (`git rm src/hooks/init.rs`); submodule files already present via auto-merge.

### `src/main.rs` (UU) — ADDITIVE MERGE
- **Kept upstream additions**: `split_leading_negations()`, `strip_outer_group()`, `require_single_script()`, Trae/OpenClaw install/uninstall dispatch.
- **Kept fork additions** (additive — not in upstream): `forward_help_to_wrapped_tools()`, `keeps_clap_help()`, `forward_help_below()`, `parse_cli()`, `cli_command()`, `RTK_OWN_RUNNERS` const (help-passthrough system).
- **Fixed merge artifact**: Duplicate `AgentTarget::Antigravity` branch in uninstall dispatch removed; Trae ordered before Antigravity per upstream structure; `uninstall_antigravity_mode` return type is `Result<()>` (not `Result<Vec<String>>`).

---

## Fork Code Dropped (superseded by upstream)

| Fork code | Reason dropped |
|---|---|
| `rtk rewrite -- "$CMD"` in hooks/claude and hooks/cursor | Upstream uses `env -u RTK_REWRITE_HOST` host-scrubbing (different approach, same goal) |
| `rtk rewrite -- $cmd` in hooks/pi/rtk.ts | Reverted to upstream; historical hashes kept in allowlist |
| `(<1.5ms overhead)` timing claim in antigravity docs | Upstream removed it |

## Fork Code Kept (genuinely additive)

| Fork code | Location | Reason kept |
|---|---|---|
| `requests_help()` + `DASH_H_IS_NOT_HELP` | `src/core/runner.rs` | Upstream has no help-passthrough capability |
| `forward_help_to_wrapped_tools()` et al. | `src/main.rs` | Help-passthrough system; upstream lacks it entirely |
| `"yadm"` in `rewrite_prefixes` | `src/discover/rules.rs` | Required for yadm→git rewrite to produce `rtk git` output |
| Fork Pi plugin historical hashes | `src/hooks/init/pi.rs` | Required for `test_all_git_pi_plugin_revisions_are_allowlisted` |

---

## Test Fixes Required

### `src/discover/registry.rs` — 5 tests updated
Auto-merged file kept fork expectations (`Unsupported`, `rtk yadm`). Upstream changed yadm to route through git rule → `rtk git`. Updated:
- `test_classify_yadm_status` → `Classification::Supported { rtk_equivalent: "rtk git", ... }`
- `test_classify_yadm_diff` → same
- `test_rewrite_yadm_status` → `Some("rtk git status")`
- `test_rewrite_yadm_commit` → `Some("rtk git commit -m x")`
- `test_rewrite_yadm_add` → `Some("rtk git add .")`

### `src/hooks/init/pi.rs` — 3 hashes added to `KNOWN_PI_PLUGIN_HASHES`
Fork's git history contains `hooks/pi/rtk.ts` revisions with `--` terminator. The `test_all_git_pi_plugin_revisions_are_allowlisted` test walks all git history. Added 3 fork-specific hashes.

---

## Quality Gate Result

```
cargo fmt --all    ✓
cargo clippy --all-targets  ✓  (zero warnings)
cargo test --all   ✓  (3901+ passed, 8 ignored)
```

Note: 3 tee/retriever tests flaked on one parallel run (pass in isolation and on re-run) — pre-existing race condition unrelated to this sync.

---

## Suggested PR

**Title**: `sync: merge upstream/develop 2026-09-30`

**Body**:
```
Merges upstream/develop into fork. Upstream wins on all conflicts.

Additive fork capabilities preserved:
- Help-passthrough system (`requests_help`, `forward_help_to_wrapped_tools`, etc.)
- yadm prefix in rewrite rules (routes `rtk yadm` → `rtk git`)
- Fork Pi plugin historical hashes in allowlist

Fork code dropped:
- `rtk rewrite -- "$CMD"` pattern in hooks (upstream uses `env -u RTK_REWRITE_HOST` instead)

Tests updated:
- 5 yadm classify/rewrite tests updated to match upstream behavior
- 3 fork Pi plugin hashes added to allowlist
```
