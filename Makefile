# API versions to generate documentation for
API_VERSIONS := \
	cluster.kubernetes-fleet.io/v1 \
	cluster.kubernetes-fleet.io/v1beta1 \
	placement.kubernetes-fleet.io/v1 \
	placement.kubernetes-fleet.io/v1beta1

.PHONY: help
help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-30s %s\n", $$1, $$2}'

.PHONY: install-tools
install-tools: ## Install required tools (crd-ref-docs)
	@echo "Installing crd-ref-docs..."
	go install github.com/elastic/crd-ref-docs@latest

.PHONY: clone-kubefleet
clone-kubefleet: ## Clone KubeFleet source repository
	@echo "Cloning KubeFleet repository..."
	@if [ -d "kubefleet-source" ]; then \
		echo "kubefleet-source directory already exists, updating to latest..."; \
		cd kubefleet-source && git fetch origin && git reset --hard origin/main; \
	else \
		git clone https://github.com/kubefleet-dev/kubefleet.git kubefleet-source; \
	fi

.PHONY: generate-api-refs
generate-api-refs: ## Generate API reference documentation
	@. scripts/generate-api-ref.sh; \
	for api in $(API_VERSIONS); do \
		generate_api_ref "$$api"; \
	done; \
	echo "✓ API references generated successfully"

.PHONY: restore-frontmatter
restore-frontmatter: ## Restore Hugo front matter to generated API references
	@. scripts/restore-frontmatter.sh; \
	weight=1; \
	for api in $(API_VERSIONS); do \
		restore_frontmatter "$$api" $$weight; \
		weight=$$((weight + 1)); \
	done; \
	echo "✓ Hugo front matter restored successfully"

.PHONY: update-api-refs
update-api-refs: clone-kubefleet generate-api-refs restore-frontmatter ## Update API references (full pipeline)
	@echo ""
	@echo "✓ API references updated successfully!"
	@echo ""
	@echo "Changed files:"
	@git diff --stat content/en/docs/api-reference/

.PHONY: update-api-refs-ci
update-api-refs-ci: clone-kubefleet generate-api-refs restore-frontmatter ## Update API references (CI pipeline - no git diff)
	@echo ""
	@echo "✓ API references updated successfully!"

.PHONY: clean
clean: ## Remove cloned KubeFleet source
	@echo "Removing kubefleet-source directory..."
	rm -rf kubefleet-source
	@echo "✓ Cleanup complete"
