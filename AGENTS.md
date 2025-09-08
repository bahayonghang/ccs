# Repository Guidelines

## Project Structure & Module Organization
- `scripts/shell/`: Core CLI scripts (`ccs.sh`, `ccs-common.sh`, `ccs.fish`).
- `scripts/install/`: Cross‑platform installers (`install.sh`, `install.bat`, quick_install/).
- `web/`: Static web UI (`index.html`) used by `ccs web`.
- `config/`: Examples and docs (e.g., `.ccs_config.toml.example`).
- `docs/`: Architecture, usage, and troubleshooting guides.
- `assets/`: Images used in README and docs.

## Build, Test, and Development Commands
- `just --list` or `make help`: Discover available tasks.
- `just install` / `make install`: Install CCS locally.
- `just test` / `make test`: Sanity tests for CLI.
- `just test-all` / `make test-all`: Test Bash/Fish variants.
- `just check-syntax` / `make check-syntax`: Shell syntax checks.
- `just web` / `make web`: Launch web UI. For development use `*-dev`.
- Node scripts: `npm test`, `npm run install` mirror core tasks.

## Coding Style & Naming Conventions
- Language: Bash (>=4), Fish supported; keep cross‑platform paths and POSIX utilities.
- Indentation: 4 spaces; functions `snake_case`; constants `UPPER_SNAKE`.
- Prefer `[[ ... ]]`, `local` vars, and built‑ins over external processes.
- Error handling via shared helpers in `ccs-common.sh` (e.g., `handle_error`, logging).
- Tools: run `just format` (shfmt) and use ShellCheck locally before PRs.

## Testing Guidelines
- Primary: `just test`, `just test-all` (or Make equivalents).
- Add new checks to both Justfile and Makefile when feasible.
- Web changes: verify `just web-dev` locally and include before/after screenshots.

## Commit & Pull Request Guidelines
- Conventional Commits with scopes, emoji allowed: examples
  - `feat(shell): add self-update`  
  - `fix(install): correct example config path`
- Branch naming: `feat/<short-name>`, `fix/<short-name>`.
- PRs must include: summary, rationale, linked issues, test plan (`just test-all`), platform notes (Linux/macOS/Windows), and screenshots for web changes.
- Keep changes minimal and focused; avoid renames unless necessary.

## Security & Configuration Tips
- Never commit secrets. Use `config/.ccs_config.toml.example` for references.
- User config lives at `~/.ccs_config.toml`; ensure permissions `chmod 600 ~/.ccs_config.toml`.
- Prefer environment variables for local testing (e.g., `CCS_LOG_LEVEL=DEBUG just test`).

## Agent-Specific Instructions
- Follow this file’s conventions for any patches.
- Update both `justfile` and `Makefile` when adding developer commands.
- Validate with `just health-check` before submitting.
