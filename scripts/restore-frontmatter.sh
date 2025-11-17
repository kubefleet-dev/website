#!/bin/bash

set -e

restore_frontmatter() {
	FILE="$1"
	TITLE="$2"
	DESC="$3"
	WEIGHT="$4"
	
	echo "Restoring Hugo front matter to ${FILE}..."
	TEMP_FILE="$(mktemp)" || exit 1
	printf '%s\n' '---' "title: ${TITLE}" "description: ${DESC}" "weight: ${WEIGHT}" '---' '' > "${TEMP_FILE}" || exit 1
	cat "${FILE}" >> "${TEMP_FILE}" || exit 1
	mv "${TEMP_FILE}" "${FILE}" || exit 1
}
