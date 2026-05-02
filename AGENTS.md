# AGENTS.md — argbash

## What this is

Argbash is a Bash argument-parsing code generator. Users annotate `.m4` template files with `# ARG_*` macros; the `argbash` CLI (which is itself a self-hosted bash script) processes them through GNU M4 (`autom4te`) to produce standalone bash scripts with argument parsing.

## Architecture

- **`bin/argbash`** — main CLI, a bash script that calls `autom4te`. Self-generated (runs argbash on its own `.m4` source).
- **`bin/argbash-init`** — scaffolding tool to create new `.m4` templates.
- **`bin/argbash-1to2`** — migration tool.
- **`src/*.m4`** — the M4 macro library. `argbash.m4` is the main entry; it `m4_include`s other files. `src/version` is a plain-text version file.
- **`resources/Makefile`** — the **primary build/test/install Makefile**. Includes `tests/regressiontests/Makefile`.
- **`tests/regressiontests/Makefile`** — generated from `tests/regressiontests/make/Makefile.m4` via `autom4te`. Contains all regression test targets.
- **`tests/unittests/check-*.m4`** — unit tests run directly through `autom4te`.

## Key commands (run from `resources/`)

```bash
# Full test suite (unit + regression + shellcheck)
make check

# Just unit tests (m4-level assertions via autom4te)
make unittests

# Just regression tests
make regressiontests

# Run a single regression test (SHELLCHECK= disables optional shellcheck)
make SHELLCHECK= test-simple

# Regenerate the regression Makefile after editing tests/regressiontests/make/*
autom4te -l m4sugar -I tests/regressiontests/make tests/regressiontests/make/Makefile.m4 -o tests/regressiontests/Makefile

# Bootstrap bin/argbash from raw M4 sources (first build / if bin/argbash is broken)
make bootstrap

# Rebuild bin/argbash from its .m4 source (normal rebuild)
make ../bin/argbash

# Rebuild bin/argbash-init
make ../bin/argbash-init

# Install system-wide
sudo make install PREFIX=/usr

# Clean generated test artifacts
make tests-clean
```

## Requirements

- `autoconf >= 2.63` (provides `autom4te`)
- `bash >= 3.0`
- `dash` (optional; enables POSIX/dash regression tests)
- `shellcheck` (optional; auto-detected, skipped if missing)

## Critical conventions

- The regression test Makefile at `tests/regressiontests/Makefile` is **generated** — do not edit it directly. Edit `tests/regressiontests/make/Makefile.m4` and regenerate.
- `bin/argbash` and `bin/argbash-init` are self-hosting: they contain both the argbash macro annotations (`# ARG_*`) and the generated parsing code. After editing the hand-written logic in `bin/argbash`, regenerate it with `make ../bin/argbash` or the `bootstrap` target.
- All `.m4` files under `src/` are the source of truth. The `bin/` scripts are derived.
- Test scripts (`.sh` in `tests/regressiontests/`) are generated from `.m4` templates by the Makefile. Run `make tests-clean` to remove them.

## M4 quoting gotchas

- M4 uses `[` and `]` for quoting. Literal brackets in user scripts must be escaped as `@<:@` and `@:>:@`.
- Literal braces: `@{:@` and `@:}@`.
- The `# [ <-- needed because of Argbash` / `# ] <-- needed because of Argbash` markers delimit the user-content section in generated scripts.

## CI

GitHub Actions (`.github/workflows/run-tests.yml`): installs deps, runs `make install`, then `make -B ../tests/regressiontests/Makefile && make check ARGBASH_EXEC=argbash ARGBASH_INIT_EXEC=argbash-init`.
