#!/usr/bin/env bash
# User-owned per-file merge hook. Servicegen never overwrites this file.
#
# Arguments:
#   1: project-relative path
#   2: current file path, or an empty string when the file does not exist
#   3: incoming generated file path
#   4: writable temporary output path for a custom merge result
#   5: default action: ADD, UPD, OVR, or SKP
#   6: 1 when the basename contains "generated", otherwise 0
#   7: 1 when the path is in scripts/merge-overwrite.txt, otherwise 0
#
# Exit codes:
#   0  keep the default servicegen action
#   10 preserve the current file (or skip an incoming new file)
#   11 replace the current file with the incoming file
#   12 install the custom result written to argument 4
# Any other exit code aborts the merge.
#
# Environment:
#   SERVICEGEN_MERGE_DRY_RUN=0|1
#   SERVICEGEN_PROJECT_DIR=<project root>
#   SERVICEGEN_INCOMING_ROOT=<unpacked generated project root>
#
# Ready-to-adapt examples (leave commented until needed):
#
# relative_path="$1"
# current_file="$2"
# incoming_file="$3"
# output_file="$4"
# default_action="$5"
# is_generated="$6"
# is_overwrite_listed="$7"
#
# case "$relative_path" in
#   .gitignore)
#     # Merge a normally preserved user file. Keep existing line order and append
#     # only new lines from the generated file.
#     if [[ -z "$current_file" ]]; then
#       exit 11
#     fi
#     awk 'NR == FNR { seen[$0] = 1; print; next } !seen[$0]++ { print }' \
#       "$current_file" "$incoming_file" > "$output_file"
#     exit 12
#     ;;
#   docs/legacy.md)
#     # Keep this user file even if its name or overwrite-list entry would make
#     # the default action replace it.
#     exit 10
#     ;;
#   README.md)
#     # Always accept the newly generated version.
#     exit 11
#     ;;
# esac
#
# # Metadata can drive a rule shared by many paths.
# if [[ "$is_overwrite_listed" == 1 && "$default_action" == OVR ]]; then
#   echo "allowing configured overwrite: $relative_path"
# fi
# if [[ "$is_generated" == 1 ]]; then
#   : # Inspect or delegate generated-file merges here.
# fi
#
# In merge-check mode, write only to the temporary output file (argument 4);
# do not modify files below SERVICEGEN_PROJECT_DIR.

exit 0