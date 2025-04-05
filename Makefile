.PHONY: lint format syntax docs
STYLUA := stylua

# -----------------------------------------------------------------------------
# Manual Targets
# -----------------------------------------------------------------------------
lint:
	$(STYLUA) --check .
format:
	stylua .
syntax:
	find . -type f -name "*.lua" -exec luac -p {} +
docs:
	nvim --headless -c "luafile utils/generate-docs.lua" -c "q"
