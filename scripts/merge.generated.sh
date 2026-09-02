#!/usr/bin/env bash
# Merge a newly generated archive into an existing project.
#
# A file is replaced only when its basename contains "generated" or its exact
# project-relative path is listed in scripts/merge-overwrite.txt (or in an
# explicit list passed with --overwrite-list). The
# user-owned scripts/merge_file.sh and scripts/merge_post.sh hooks may customize
# that policy without changing this generated merge engine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_STATE_DIR="$PROJECT_DIR/.servicegen"
MERGE_LOG="$LOCAL_STATE_DIR/merge.log"
mkdir -p "$LOCAL_STATE_DIR"
: > "$MERGE_LOG"

log() {
    printf '%s\n' "$*"
    printf '%s\n' "$*" >> "$MERGE_LOG"
}

log_error() {
    printf '%s\n' "$*" >&2
    printf '%s\n' "$*" >> "$MERGE_LOG"
}

log "Servicegen merge started at $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
log "Log: $MERGE_LOG"

DRY_RUN=0
REMOVE_STALE=0
ARCHIVE=""
EXPLICIT_OVERWRITE_LIST=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --remove-stale)
            REMOVE_STALE=1
            shift
            ;;
        --overwrite-list)
            if [[ $# -lt 2 || -z "$2" ]]; then
                log_error "[SG_MERGE_INVALID_ARGUMENT] --overwrite-list requires a file"
                exit 2
            fi
            EXPLICIT_OVERWRITE_LIST="$2"
            shift 2
            ;;
        -*)
            log_error "[SG_MERGE_INVALID_ARGUMENT] unsupported option '$1'"
            exit 2
            ;;
        *)
            if [[ -n "$ARCHIVE" ]]; then
                log_error "[SG_MERGE_INVALID_ARGUMENT] only one archive may be specified"
                exit 2
            fi
            ARCHIVE="$1"
            shift
            ;;
    esac
done

if [[ -z "$ARCHIVE" ]]; then
    log_error "[SG_MERGE_INVALID_ARGUMENT] Usage: $0 [--dry-run] [--remove-stale] [--overwrite-list <file>] <archive.zip|archive.tar.gz>"
    exit 2
fi
if [[ ! -f "$ARCHIVE" ]]; then
    log_error "[SG_MERGE_INVALID_ARGUMENT] archive '$ARCHIVE' was not found"
    exit 1
fi
if [[ -n "$EXPLICIT_OVERWRITE_LIST" && ! -f "$EXPLICIT_OVERWRITE_LIST" ]]; then
    log_error "[SG_MERGE_INVALID_ARGUMENT] overwrite list '$EXPLICIT_OVERWRITE_LIST' was not found"
    exit 1
fi

OVERWRITE_LIST="$SCRIPT_DIR/merge-overwrite.txt"
MERGE_FILE_HOOK="$SCRIPT_DIR/merge_file.sh"
MERGE_POST_HOOK="$SCRIPT_DIR/merge_post.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/servicegen-merge.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

log "Unpacking '$ARCHIVE' ..."
case "$ARCHIVE" in
    *.zip) unzip -q "$ARCHIVE" -d "$TMP_DIR" ;;
    *.tar.gz|*.tgz) tar -xzf "$ARCHIVE" -C "$TMP_DIR" ;;
    *)
        log_error "[SG_MERGE_UNSUPPORTED_ARCHIVE] unsupported archive format (supported: .zip, .tar.gz)"
        exit 1
        ;;
esac

SRC_ROOT=""
for candidate in "$TMP_DIR"/*/; do
    if [[ -d "$candidate" ]]; then
        SRC_ROOT="${candidate%/}"
        break
    fi
done
if [[ -z "$SRC_ROOT" ]]; then
    SRC_ROOT="$TMP_DIR"
fi

validate_relative_path() {
    local path="$1"
    if [[ -z "$path" || "$path" == /* || "$path" == "." ||
          "$path" == ".." || "$path" == ../* || "$path" == */../* ||
          "$path" == */.. ]]; then
        return 1
    fi
}

# The incoming list is authoritative for this merge, so both additions and
# removals take effect immediately. Fall back to the installed list only for
# legacy archives that do not carry one.
INCOMING_OVERWRITE_LIST="$SRC_ROOT/scripts/merge-overwrite.txt"
OVERWRITE_PATHS=()
ACTIVE_OVERWRITE_LIST="$OVERWRITE_LIST"
if [[ -n "$EXPLICIT_OVERWRITE_LIST" ]]; then
    ACTIVE_OVERWRITE_LIST="$EXPLICIT_OVERWRITE_LIST"
elif [[ -f "$INCOMING_OVERWRITE_LIST" ]]; then
    ACTIVE_OVERWRITE_LIST="$INCOMING_OVERWRITE_LIST"
fi
log "Overwrite list: $ACTIVE_OVERWRITE_LIST"
for active_list in "$ACTIVE_OVERWRITE_LIST"; do
    [[ -f "$active_list" ]] || continue
    while IFS= read -r path || [[ -n "$path" ]]; do
        path="${path#"${path%%[![:space:]]*}"}"
        path="${path%"${path##*[![:space:]]}"}"
        [[ -z "$path" || "$path" == \#* ]] && continue
        path="${path#./}"
        if ! validate_relative_path "$path"; then
            log_error "[SG_MERGE_INVALID_PATH] invalid path in $active_list: '$path'"
            exit 1
        fi
        OVERWRITE_PATHS+=("$path")
    done < "$active_list"
done

is_overwrite_path() {
    local path="$1"
    local listed
    for listed in "${OVERWRITE_PATHS[@]:-}"; do
        [[ "$listed" == "$path" ]] && return 0
    done
    return 1
}

is_generated_path() {
    [[ "$(basename "$1")" == *generated* ]]
}

# These files are produced by language tools after the servicegen archive is
# merged. Their own clean-generation commands own stale-file removal.
is_external_generated_output() {
    local path="$1"
    [[ "$path" == */src/generated/grpc/proto/* ||
       "$path" == */src/generated/http/index.generated.ts ||
       "$path" == */src/generated/http/zod.generated.ts ]]
}

ADDED=0
UPDATED=0
OVERWRITTEN=0
PRESERVED=0
STALE=0
REMOVED=0
HOOK_OVERRIDES=0
POST_HOOKS=0
SELF_UPDATE=""

if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Merge preview (no files will be changed):"
else
    log "Merging generated project:"
fi

# Resolve every per-file hook before changing the project. A failing hook thus
# cannot leave a partially applied merge behind.
while IFS= read -r src; do
    rel="${src#"$SRC_ROOT"/}"
    validate_relative_path "$rel" || {
        log_error "[SG_MERGE_INVALID_PATH] invalid archive path '$rel'"
        exit 1
    }
    dst="$PROJECT_DIR/$rel"
    decision="$TMP_DIR/decisions/$rel"
    hook_output="$TMP_DIR/hook-output/$rel"
    mkdir -p "$(dirname "$decision")" "$(dirname "$hook_output")"

    generated_flag=0
    overwrite_flag=0
    if is_generated_path "$rel"; then generated_flag=1; fi
    if is_overwrite_path "$rel"; then overwrite_flag=1; fi
    if [[ ! -f "$dst" ]]; then
        default_action="ADD"
    elif [[ "$generated_flag" -eq 1 ]]; then
        default_action="UPD"
    elif [[ "$overwrite_flag" -eq 1 ]]; then
        default_action="OVR"
    else
        default_action="SKP"
    fi
    action="$default_action"

    if [[ -x "$MERGE_FILE_HOOK" ]]; then
        current_path=""
        if [[ -f "$dst" ]]; then current_path="$dst"; fi
        hook_log="$TMP_DIR/file-hook.log"
        : > "$hook_log"
        hook_status=0
        SERVICEGEN_MERGE_DRY_RUN="$DRY_RUN" \
        SERVICEGEN_PROJECT_DIR="$PROJECT_DIR" \
        SERVICEGEN_INCOMING_ROOT="$SRC_ROOT" \
            "$MERGE_FILE_HOOK" \
            "$rel" "$current_path" "$src" "$hook_output" \
            "$default_action" "$generated_flag" "$overwrite_flag" \
            > "$hook_log" 2>&1 || hook_status=$?
        while IFS= read -r line || [[ -n "$line" ]]; do
            log "    hook[$rel]: $line"
        done < "$hook_log"
        case "$hook_status" in
            0) ;;
            10) action="SKP" ;;
            11)
                if [[ -f "$dst" ]]; then action="OVR"; else action="ADD"; fi
                ;;
            12)
                if [[ ! -f "$hook_output" ]]; then
                    log_error "[SG_MERGE_HOOK_OUTPUT_MISSING] hook for '$rel' returned 12 but did not write '$hook_output'"
                    exit 1
                fi
                if [[ -f "$dst" ]]; then action="MRG"; else action="ADD_HOOK"; fi
                ;;
            *)
                log_error "[SG_MERGE_HOOK_FAILED] hook for '$rel' failed with exit code $hook_status"
                exit "$hook_status"
                ;;
        esac
    fi
    if [[ "$action" != "$default_action" || "$action" == "MRG" || "$action" == "ADD_HOOK" ]]; then
        HOOK_OVERRIDES=$((HOOK_OVERRIDES + 1))
    fi
    printf '%s\n' "$action" > "$decision"
done < <(find "$SRC_ROOT" -type f -print | LC_ALL=C sort)

while IFS= read -r src; do
    rel="${src#"$SRC_ROOT"/}"
    dst="$PROJECT_DIR/$rel"
    action="$(cat "$TMP_DIR/decisions/$rel")"
    selected_src="$src"
    if [[ "$action" == "MRG" || "$action" == "ADD_HOOK" ]]; then
        selected_src="$TMP_DIR/hook-output/$rel"
    fi

    if [[ "$action" == "ADD" || "$action" == "ADD_HOOK" ]]; then
        if [[ "$action" == "ADD_HOOK" ]]; then log "  ADD  $rel [hook]"; else log "  ADD  $rel"; fi
        ADDED=$((ADDED + 1))
        if [[ "$DRY_RUN" -eq 0 ]]; then
            mkdir -p "$(dirname "$dst")"
            cp -p "$selected_src" "$dst"
            touch "$dst"
        fi
    elif [[ "$action" == "UPD" ]]; then
        log "  UPD  $rel"
        UPDATED=$((UPDATED + 1))
        if [[ "$DRY_RUN" -eq 0 ]]; then
            if [[ "$dst" == "$SCRIPT_DIR/merge.generated.sh" ]]; then
                SELF_UPDATE="$SCRIPT_DIR/.merge-script.new"
                cp -p "$selected_src" "$SELF_UPDATE"
                touch "$SELF_UPDATE"
            else
                cp -p "$selected_src" "$dst"
                touch "$dst"
            fi
        fi
    elif [[ "$action" == "OVR" || "$action" == "MRG" ]]; then
        if [[ "$action" == "MRG" ]]; then log "  MRG  $rel [hook]"; else log "  OVR  $rel"; fi
        OVERWRITTEN=$((OVERWRITTEN + 1))
        if [[ "$DRY_RUN" -eq 0 ]]; then
            if [[ "$dst" == "$SCRIPT_DIR/merge.generated.sh" ]]; then
                SELF_UPDATE="$SCRIPT_DIR/.merge-script.new"
                cp -p "$selected_src" "$SELF_UPDATE"
                touch "$SELF_UPDATE"
            else
                cp -p "$selected_src" "$dst"
                touch "$dst"
            fi
        fi
    elif [[ "$action" == "SKP" ]]; then
        if [[ -f "$dst" ]]; then
            log "  SKP  $rel"
            PRESERVED=$((PRESERVED + 1))
        else
            log "  SKP  $rel [hook]"
        fi
    else
        log_error "[SG_MERGE_HOOK_INVALID_ACTION] invalid resolved action '$action' for '$rel'"
        exit 1
    fi
done < <(find "$SRC_ROOT" -type f -print | LC_ALL=C sort)

log "Checking for stale generated or explicitly overwritten files:"
while IFS= read -r current; do
    rel="${current#"$PROJECT_DIR"/}"
    if ! is_generated_path "$rel" && ! is_overwrite_path "$rel"; then
        continue
    fi
    is_external_generated_output "$rel" && continue
    if [[ ! -f "$SRC_ROOT/$rel" ]]; then
        log "  STALE $rel"
        STALE=$((STALE + 1))
        if [[ "$REMOVE_STALE" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
            validate_relative_path "$rel" || {
                log_error "[SG_MERGE_INVALID_PATH] refusing to remove invalid path '$rel'"
                exit 1
            }
            rm -f "$current"
            REMOVED=$((REMOVED + 1))
        fi
    fi
done < <(
    find "$PROJECT_DIR" \
        \( -name .git -o \
           -name .servicegen -o \
           -name .dependencies -o \
           -name .artifacts -o \
           -name .cache -o \
           -name .venv -o \
           -name .local-dependencies -o \
           -name __pycache__ -o \
           -name build -o \
           -name dist -o \
           -name dist-test -o \
           -name node_modules -o \
           -name target -o \
           -name tmp -o \
           -name tools \) -prune -o \
        -type f -print | LC_ALL=C sort
)
if [[ "$STALE" -eq 0 ]]; then
    log "  none"
elif [[ "$REMOVE_STALE" -eq 0 ]]; then
    log "  Stale files were not removed; use --remove-stale explicitly."
fi

if [[ -x "$MERGE_POST_HOOK" ]]; then
    POST_HOOK_OUTPUT="$TMP_DIR/post-hook.log"
    POST_HOOK_STATUS=0
    SERVICEGEN_MERGE_DRY_RUN="$DRY_RUN" \
    SERVICEGEN_PROJECT_DIR="$PROJECT_DIR" \
    SERVICEGEN_INCOMING_ROOT="$SRC_ROOT" \
        "$MERGE_POST_HOOK" "$PROJECT_DIR" "$SRC_ROOT" \
        > "$POST_HOOK_OUTPUT" 2>&1 || POST_HOOK_STATUS=$?
    while IFS= read -r line || [[ -n "$line" ]]; do
        log "    post-hook: $line"
    done < "$POST_HOOK_OUTPUT"
    if [[ "$POST_HOOK_STATUS" -ne 0 ]]; then
        log_error "[SG_MERGE_HOOK_FAILED] post-merge hook failed with exit code $POST_HOOK_STATUS"
        exit "$POST_HOOK_STATUS"
    fi
    POST_HOOKS=$((POST_HOOKS + 1))
fi

VALIDATOR="$SRC_ROOT/scripts/merge_validate.generated.py"
VALIDATION_STATUS=0
if [[ -f "$VALIDATOR" ]]; then
    validator_args=(
        --project "$PROJECT_DIR"
        --incoming "$SRC_ROOT"
        --overwrite-list "$ACTIVE_OVERWRITE_LIST"
    )
    if [[ "$DRY_RUN" -eq 0 ]]; then
        validator_args+=(--write-task)
    fi
    VALIDATOR_OUTPUT="$TMP_DIR/validator.log"
    python3 "$VALIDATOR" "${validator_args[@]}" > "$VALIDATOR_OUTPUT" 2>&1 || VALIDATION_STATUS=$?
    while IFS= read -r line || [[ -n "$line" ]]; do
        log "$line"
    done < "$VALIDATOR_OUTPUT"
fi

log ""
log "Merge report:"
log "  added: $ADDED"
log "  generated updated: $UPDATED"
log "  exception-list overwritten: $OVERWRITTEN"
log "  user files preserved: $PRESERVED"
    log "  stale managed files: $STALE"
log "  stale files removed: $REMOVED"
log "  file hook overrides: $HOOK_OVERRIDES"
log "  post hooks executed: $POST_HOOKS"
if [[ "$DRY_RUN" -eq 1 ]]; then
    log "  mode: dry-run; project was not changed"
fi

if [[ "$DRY_RUN" -eq 0 && -n "$SELF_UPDATE" ]]; then
    mv "$SELF_UPDATE" "$SCRIPT_DIR/merge.generated.sh"
fi

if [[ "$VALIDATION_STATUS" -ne 0 ]]; then
    exit "$VALIDATION_STATUS"
fi