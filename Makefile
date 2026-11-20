NVIM ?= nvim
SELENE_PATHS := init.lua lua after tests

.PHONY: test test-install lint clean

## Headless smoke test (uses whatever language servers Mason already installed)
test:
	$(NVIM) --clean -l tests/smoke.lua $(ARGS)

## Same, but first installs the language servers/formatters with Mason (what CI runs)
test-install:
	$(NVIM) --clean -l tests/smoke.lua --install $(ARGS)

lint:
	stylua --check .
	selene $(SELENE_PATHS)

## Remove the test sandbox (plugins, parsers, Mason packages)
clean:
	rm -rf .tests
