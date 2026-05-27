#!/usr/bin/env bash
set -euo pipefail
## update_release_metadata.sh
## Purpose:
## 1) Run scripts/update_matrix.py to refresh the shared Molecule matrix
##    (molecule/shared/vars.yml).
## 2) Run scripts/render_inventory.py to regenerate scenario inventories.
## 3) Render meta/main.yml from templates/meta_main.yml.j2 using that shared vars file.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

PYTHON_BIN="python3"
SKIP_UPDATE_MATRIX="false"
SKIP_RENDER_INVENTORY="false"
VARS_FILE="$REPO_ROOT/molecule/shared/vars.yml"
TEMPLATE_FILE="$REPO_ROOT/templates/meta_main.yml.j2"
OUTPUT_FILE="$REPO_ROOT/meta/main.yml"
VERBOSE="false"

log() {
    printf '%s\n' "$*"
}

usage() {
    sed -n '1,140p' "$0"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --python)
            PYTHON_BIN="$2"
            shift 2
            ;;
        --skip-update-matrix)
            SKIP_UPDATE_MATRIX="true"
            shift
            ;;
        --skip-render-inventory)
            SKIP_RENDER_INVENTORY="true"
            shift
            ;;
        --vars-file)
            VARS_FILE="$2"
            shift 2
            ;;
        --template)
            TEMPLATE_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'ERROR: Unknown argument: %s\n' "$1" >&2
            exit 2
            ;;
    esac
done

if [[ "$VERBOSE" == "true" ]]; then
    set -x
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    printf 'ERROR: Python interpreter not found: %s\n' "$PYTHON_BIN" >&2
    exit 3
fi

UPDATE_MATRIX_SCRIPT="$REPO_ROOT/scripts/update_matrix.py"
RENDER_INVENTORY_SCRIPT="$REPO_ROOT/scripts/render_inventory.py"
RENDER_META_SCRIPT="$REPO_ROOT/scripts/render_meta_main.py"

if [[ ! -f "$RENDER_META_SCRIPT" ]]; then
    printf 'ERROR: Renderer script not found: %s\n' "$RENDER_META_SCRIPT" >&2
    exit 4
fi

if [[ "$SKIP_UPDATE_MATRIX" != "true" ]]; then
    if [[ ! -f "$UPDATE_MATRIX_SCRIPT" ]]; then
        printf 'ERROR: Matrix update script not found: %s\n' "$UPDATE_MATRIX_SCRIPT" >&2
        exit 5
    fi
    log '==> Refreshing Molecule matrix'
    (cd "$REPO_ROOT" && "$PYTHON_BIN" "$UPDATE_MATRIX_SCRIPT")
else
    log '==> Skipping matrix refresh (requested)'
fi

if [[ "$SKIP_RENDER_INVENTORY" != "true" ]]; then
    if [[ ! -f "$RENDER_INVENTORY_SCRIPT" ]]; then
        printf 'ERROR: Inventory render script not found: %s\n' "$RENDER_INVENTORY_SCRIPT" >&2
        exit 6
    fi
    log '==> Regenerating Molecule inventories'
    (cd "$REPO_ROOT" && "$PYTHON_BIN" "$RENDER_INVENTORY_SCRIPT")
else
    log '==> Skipping inventory regeneration (requested)'
fi

if [[ ! -f "$VARS_FILE" ]]; then
    printf 'ERROR: Shared vars file not found: %s\n' "$VARS_FILE" >&2
    exit 7
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    printf 'ERROR: Template file not found: %s\n' "$TEMPLATE_FILE" >&2
    exit 8
fi

mkdir -p "$(dirname -- "$OUTPUT_FILE")"

log '==> Rendering meta/main.yml from shared matrix'
(
    cd "$REPO_ROOT" && \
    "$PYTHON_BIN" "$RENDER_META_SCRIPT" \
        --vars-file "$VARS_FILE" \
        --template "$TEMPLATE_FILE" \
        --output "$OUTPUT_FILE"
)

log '==> Done'
log "Shared vars : $VARS_FILE"
log "Template    : $TEMPLATE_FILE"
log "Output      : $OUTPUT_FILE"
log ''
log 'Suggested next steps:'
log '  1) git diff -- meta/main.yml molecule/'
log '  2) molecule test -s default'
log '  3) Commit if everything looks good'
