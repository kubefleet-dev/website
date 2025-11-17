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
	@echo "Verifying kubefleet-source directory exists..."
	@test -d kubefleet-source/apis || \
		(echo "Error: kubefleet-source/apis not found. Run 'make clone-kubefleet' first." && exit 1)
	
	@echo "Generating cluster.kubernetes-fleet.io/v1 API reference..."
	crd-ref-docs \
		--source-path=kubefleet-source/apis/cluster/v1 \
		--config=configs/api-refs-generator.yaml \
		--renderer=markdown \
		--output-path=content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1.md
	
	@echo "Generating cluster.kubernetes-fleet.io/v1beta1 API reference..."
	crd-ref-docs \
		--source-path=kubefleet-source/apis/cluster/v1beta1 \
		--config=configs/api-refs-generator.yaml \
		--renderer=markdown \
		--output-path=content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1beta1.md
	
	@echo "Generating placement.kubernetes-fleet.io/v1 API reference..."
	crd-ref-docs \
		--source-path=kubefleet-source/apis/placement/v1 \
		--config=configs/api-refs-generator.yaml \
		--renderer=markdown \
		--output-path=content/en/docs/api-reference/placement.kubernetes-fleet.io/v1.md
	
	@echo "Generating placement.kubernetes-fleet.io/v1beta1 API reference..."
	crd-ref-docs \
		--source-path=kubefleet-source/apis/placement/v1beta1 \
		--config=configs/api-refs-generator.yaml \
		--renderer=markdown \
		--output-path=content/en/docs/api-reference/placement.kubernetes-fleet.io/v1beta1.md
	
	@echo "✓ API references generated successfully"

.PHONY: restore-frontmatter
restore-frontmatter: ## Restore Hugo front matter to generated API references
	@echo "Checking generated files exist..."
	@test -f content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1.md || \
		(echo "Error: cluster.kubernetes-fleet.io/v1.md not found. Generation may have failed." && exit 1)
	@test -f content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1beta1.md || \
		(echo "Error: cluster.kubernetes-fleet.io/v1beta1.md not found. Generation may have failed." && exit 1)
	@test -f content/en/docs/api-reference/placement.kubernetes-fleet.io/v1.md || \
		(echo "Error: placement.kubernetes-fleet.io/v1.md not found. Generation may have failed." && exit 1)
	@test -f content/en/docs/api-reference/placement.kubernetes-fleet.io/v1beta1.md || \
		(echo "Error: placement.kubernetes-fleet.io/v1beta1.md not found. Generation may have failed." && exit 1)
	
	@. scripts/restore-frontmatter.sh; \
	restore_frontmatter content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1.md "cluster.kubernetes-fleet.io/v1" "API reference for cluster.kubernetes-fleet.io/v1" 1; \
	restore_frontmatter content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1beta1.md "cluster.kubernetes-fleet.io/v1beta1" "API reference for cluster.kubernetes-fleet.io/v1beta1" 2; \
	restore_frontmatter content/en/docs/api-reference/placement.kubernetes-fleet.io/v1.md "placement.kubernetes-fleet.io/v1" "API reference for placement.kubernetes-fleet.io/v1" 3; \
	restore_frontmatter content/en/docs/api-reference/placement.kubernetes-fleet.io/v1beta1.md "placement.kubernetes-fleet.io/v1beta1" "API reference for placement.kubernetes-fleet.io/v1beta1" 4; \
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
