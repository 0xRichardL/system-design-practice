.PHONY: init render

init:
	npm install -g @mermaid-js/mermaid-cli

render:
	./scripts/render.sh $(filter-out $@,$(MAKECMDGOALS))

%:
	@: