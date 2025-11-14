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
		echo "kubefleet-source directory already exists, pulling latest..."; \
		cd kubefleet-source && git pull origin main; \
	else \
		git clone https://github.com/kubefleet-dev/kubefleet.git kubefleet-source; \
	fi

.PHONY: generate-api-refs
generate-api-refs: ## Generate API reference documentation
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
	@echo "Restoring Hugo front matter to cluster.kubernetes-fleet.io/v1.md..."
	@sed -i '1i---\ntitle: cluster.kubernetes-fleet.io/v1\ndescription: API reference for cluster.kubernetes-fleet.io/v1\nweight: 1\n---\n' \
		content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1.md
	
	@echo "Restoring Hugo front matter to cluster.kubernetes-fleet.io/v1beta1.md..."
	@sed -i '1i---\ntitle: cluster.kubernetes-fleet.io/v1beta1\ndescription: API reference for cluster.kubernetes-fleet.io/v1beta1\nweight: 2\n---\n' \
		content/en/docs/api-reference/cluster.kubernetes-fleet.io/v1beta1.md
	
	@echo "Restoring Hugo front matter to placement.kubernetes-fleet.io/v1.md..."
	@sed -i '1i---\ntitle: placement.kubernetes-fleet.io/v1\ndescription: API reference for placement.kubernetes-fleet.io/v1\nweight: 3\n---\n' \
		content/en/docs/api-reference/placement.kubernetes-fleet.io/v1.md
	
	@echo "Restoring Hugo front matter to placement.kubernetes-fleet.io/v1beta1.md..."
	@sed -i '1i---\ntitle: placement.kubernetes-fleet.io/v1beta1\ndescription: API reference for placement.kubernetes-fleet.io/v1beta1\nweight: 4\n---\n' \
		content/en/docs/api-reference/placement.kubernetes-fleet.io/v1beta1.md
	
	@echo "✓ Hugo front matter restored successfully"

.PHONY: update-api-refs
update-api-refs: clone-kubefleet generate-api-refs restore-frontmatter ## Update API references (full pipeline)
	@echo ""
	@echo "✓ API references updated successfully!"
	@echo ""
	@echo "Changed files:"
	@git diff --stat content/en/docs/api-reference/

.PHONY: clean
clean: ## Remove cloned KubeFleet source
	@echo "Removing kubefleet-source directory..."
	rm -rf kubefleet-source
	@echo "✓ Cleanup complete"
