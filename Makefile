.PHONY: setup render render-all check help

setup:
	./scripts/setup.sh

render:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make render FILE=path/to/diagram.mmd" >&2; \
		exit 1; \
	fi
	./scripts/render.sh "$(FILE)"

render-all:
	./scripts/render-all.sh

check:
	./scripts/check.sh

help:
	@echo "Available commands:"
	@echo "  make setup                  Install the pinned renderer and browser"
	@echo "  make render FILE=<file>     Render one Mermaid source beside the input"
	@echo "  make render-all             Render every Mermaid source"
	@echo "  make check                  Validate sources and generated SVG metadata"
