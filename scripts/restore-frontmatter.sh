#!/bin/bash

set -e

restore_frontmatter() {
	TITLE="$1"
	WEIGHT="$2"
	FILE="content/en/docs/api-reference/${TITLE}.md"

	# Check if file exists
	if [ ! -f "${FILE}" ]; then
		echo "Error: ${FILE} not found. Generation may have failed."
		exit 1
	fi

	echo "Restoring Hugo front matter to ${FILE}..."
	TEMP_FILE="$(mktemp)" || exit 1
	printf '%s\n' '---' "title: ${TITLE}" "weight: ${WEIGHT}" '---' '' > "${TEMP_FILE}" || exit 1
	cat "${FILE}" >> "${TEMP_FILE}" || exit 1
	mv "${TEMP_FILE}" "${FILE}" || exit 1
}
