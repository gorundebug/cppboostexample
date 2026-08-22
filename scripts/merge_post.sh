#!/usr/bin/env bash
# User-owned post-merge hook. Servicegen never overwrites this file.
#
# Arguments:
#   1: project root
#   2: unpacked incoming generated project root
#
# SERVICEGEN_MERGE_DRY_RUN is 1 for merge-check. A custom hook must only report
# intended work in that mode and must not modify the project. Any non-zero exit
# code aborts the merge before post-merge interface validation.
#
# Ready-to-adapt examples (leave commented until needed):
#
# project_root="$1"
# incoming_root="$2"
#
# if [[ "${SERVICEGEN_MERGE_DRY_RUN:-0}" == 1 ]]; then
#   echo "would run project-specific formatting and validation"
#   exit 0
# fi
#
# # Run an existing user-owned workflow after generated files are installed.
# (cd "$project_root" && make format && make test)
#
# # Or delegate to a project script. The incoming tree remains available when
# # the workflow needs to compare old and newly generated project-level files.
# "$project_root/scripts/post_merge_project.sh" "$project_root" "$incoming_root"

exit 0
