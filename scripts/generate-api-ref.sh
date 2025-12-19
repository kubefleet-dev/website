#!/bin/bash

set -e

generate_api_ref() {
	TITLE="$1"

	# Extract API group and version from the full path (e.g., "cluster.kubernetes-fleet.io/v1")
	API_GROUP="${TITLE%%/*}"  # Get everything before the first /
	VERSION="${TITLE##*/}"    # Get everything after the last /

	# Extract the short API group name (cluster or placement) from cluster.kubernetes-fleet.io
	API_GROUP_SHORT="${API_GROUP%%.*}"  # Get everything before the first .

	SOURCE_PATH="kubefleet-source/apis/${API_GROUP_SHORT}/${VERSION}"
	OUTPUT_PATH="content/en/docs/api-reference/${TITLE}.md"

	# Check if source path exists
	if [ ! -d "${SOURCE_PATH}" ]; then
		echo "Error: ${SOURCE_PATH} not found. Run 'make clone-kubefleet' first."
		exit 1
	fi

	echo "Generating ${TITLE} API reference..."
	crd-ref-docs \
		--source-path="${SOURCE_PATH}" \
		--config=configs/api-refs-generator.yaml \
		--renderer=markdown \
		--output-path="${OUTPUT_PATH}"
}
