# nvim

My Neovim config (lazy.nvim, Mason, nvim-treesitter `main`, blink.cmp, conform, nvim-lint, telescope).

## Testing

A headless smoke test opens a fixture for each of JSON, Go, HTML, CSS, Lua,
Terraform and Python, waits for treesitter and the language servers, and
fails on any deprecation warning, error or server that doesn't attach.
Everything runs in an isolated sandbox under `.tests/`, so your real
`~/.local/share/nvim` is never touched.

```sh
make test                 # uses the language servers already installed in the sandbox
make test-install         # installs servers/formatters with Mason first (what CI runs)
make test ARGS=main.go    # just one fixture
make test NVIM=~/bin/nvim-nightly
make lint                 # stylua --check . && selene
make clean                # delete the .tests/ sandbox
```

Requirements: `git`, `make`, a C compiler and the
[tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases) ≥ 0.26.1
on `PATH`. `go` is needed for `make test-install` (Mason builds gopls).
Servers that aren't installed are reported as `skip`, not failures.

Known harmless upstream deprecations are allow-listed in
`tests/smoke/allowlist.lua`. Deprecations coming from this config are never
allow-listed.

CI (`.github/workflows/nvim.yml`) runs the smoke test on Neovim stable and
nightly, plus stylua and selene.
