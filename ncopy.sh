#!/usr/bin/env bash

# ==============================================================================
# NCOPY v5 - Professional Rust Iteration Tool
# Developed for: هیناتا (Hinata)
# Features: Snapshots, Backups, Rollbacks, Cargo Integration, Hash Logging
# ==============================================================================

set -euo pipefail

# --- Configuration & Defaults ---
SCRIPT_NAME="$(basename -- "$0")"
DEFAULT_SOURCE="src/main.rs"
DEFAULT_TEMPLATE="./mp.rs"
DEFAULT_SNAP_DIR="src/snapshots"
DEFAULT_LOG=".ncopy.log"

# --- State Variables ---
SOURCE_FILE="$DEFAULT_SOURCE"
TEMPLATE_FILE="$DEFAULT_TEMPLATE"
SNAP_DIR="$DEFAULT_SNAP_DIR"
LOG_NAME="$DEFAULT_LOG"

# --- Flags ---
DO_FMT=0
DO_CHECK=0
DO_GIT_CHECK=1
VERBOSE=0
DRY_RUN=0
FORCE=0

# --- Colors for TTY ---
if [[ -t 1 ]]; then
    C_RES='\033[0m'
    C_BOLD='\033[1m'
    C_RED='\033[31m'
    C_GRN='\033[32m'
    C_YLW='\033[33m'
    C_BLU='\033[34m'
else
    C_RES='' C_BOLD='' C_RED='' C_GRN='' C_YLW='' C_BLU=''
fi

# --- Helper Functions ---
info()    { printf "${C_BLU}[INFO]${C_RES} %s\n" "$1"; }
success() { printf "${C_GRN}[OK]${C_RES}   %s\n" "$1"; }
warn()    { printf "${C_YLW}[WARN]${C_RES} %s\n" "$1" >&2; }
error()   { printf "${C_RED}[ERR]${C_RES}  %s\n" "$1" >&2; }
die()     { error "$1"; exit 1; }

# --- System Checks ---
check_rust_env() {
    [[ -f "Cargo.toml" ]] || die "Not in a Rust project root (Cargo.toml missing)."
    if [[ "$DO_GIT_CHECK" -eq 1 ]]; then
        if [[ -d ".git" ]]; then
            if ! grep -qs "$SNAP_DIR" .gitignore; then
                warn "'$SNAP_DIR' is not in .gitignore. Snapshots might be tracked by Git."
            fi
        fi
    fi
}

get_sha256() {
    sha256sum -- "$1" | awk '{print $1}'
}

log_event() {
    local msg="$1"
    local file="${2:-}"
    local hash=""
    [[ -n "$file" && -f "$file" ]] && hash="$(get_sha256 "$file")"
    
    local entry="$(date '+%Y-%m-%d %H:%M:%S') | $msg ${hash:+[SHA:$hash]}"
    
    if [[ "$DRY_RUN" -eq 1 ]]; then
        info "[dry-run] Log entry: $entry"
    else
        mkdir -p -- "$SNAP_DIR"
        printf '%s\n' "$entry" >> "$SNAP_DIR/$LOG_NAME"
    fi
}

# --- Core Logic ---
get_next_index() {
    local max=0
    shopt -s nullglob
    for f in "$SNAP_DIR"/*; do
        local base=$(basename "$f")
        if [[ "$base" =~ ^main_([0-9]{3})_ ]]; then
            local idx=$((10#${BASH_REMATCH[1]}))
            (( idx > max )) && max=$idx
        fi
    done
    printf "%03d" $((max + 1))
}

create_snapshot() {
    local src="$1"
    local idx=$(get_next_index)
    local ts=$(date '+%Y%m%d_%H%M%S')
    local target="$SNAP_DIR/main_${idx}_${ts}.rs"

    info "Creating snapshot #$idx..."
    if [[ "$DRY_RUN" -eq 1 ]]; then
        info "[dry-run] cp -p $src $target"
    else
        mkdir -p -- "$SNAP_DIR"
        cp -p -- "$src" "$target"
        log_event "Snapshot created: $(basename "$target")" "$target"
        success "Snapshot saved: $target"
    fi
}

create_backup() {
    local src="$1"
    local ts=$(date '+%Y%m%d_%H%M%S')
    local bak="$(dirname "$src")/.$(basename "$src").bak.$ts"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        info "[dry-run] Backup $src -> $bak"
    else
        cp -p -- "$src" "$bak"
        log_event "Backup created: $(basename "$bak")" "$bak"
    fi
}

perform_reset() {
    if cmp -s -- "$TEMPLATE_FILE" "$SOURCE_FILE"; then
        info "Source and Template are identical. Skipping reset."
        return 0
    fi

    create_backup "$SOURCE_FILE"
    
    info "Resetting $SOURCE_FILE from $TEMPLATE_FILE..."
    if [[ "$DRY_RUN" -eq 1 ]]; then
        info "[dry-run] cp $TEMPLATE_FILE $SOURCE_FILE"
    else
        cp -p -- "$TEMPLATE_FILE" "$SOURCE_FILE"
        log_event "Reset performed from $TEMPLATE_FILE" "$SOURCE_FILE"
        success "Reset complete."
    fi

    # Hooks
    [[ "$DO_FMT" -eq 1 ]] && { info "Running cargo fmt..."; cargo fmt; }
    [[ "$DO_CHECK" -eq 1 ]] && { info "Running cargo check..."; cargo check || warn "Cargo check failed!"; }
}

# --- Subcommands ---
cmd_run() {
    create_snapshot "$SOURCE_FILE"
    perform_reset
}

cmd_latest() {
    local last=$(ls -1 "$SNAP_DIR"/main_*.rs 2>/dev/null | sort | tail -n 1)
    if [[ -z "$last" ]]; then
        warn "No snapshots found."
    else
        info "Latest snapshot: $last"
        [[ "$VERBOSE" -eq 1 ]] && { printf "${C_BOLD}Content Preview:${C_RES}\n"; head -n 20 "$last"; }
    fi
}

cmd_rollback() {
    local latest_bak=$(ls -1 "$(dirname "$SOURCE_FILE")"/.*.bak.* 2>/dev/null | sort | tail -n 1)
    [[ -z "$latest_bak" ]] && die "No backup files found."
    
    info "Rolling back from $latest_bak..."
    if [[ "$DRY_RUN" -eq 1 ]]; then
        info "[dry-run] Rollback to $SOURCE_FILE"
    else
        cp -p -- "$latest_bak" "$SOURCE_FILE"
        success "Rollback successful."
        log_event "Rollback from $latest_bak" "$SOURCE_FILE"
    fi
}

cmd_clean() {
    if [[ "$FORCE" -ne 1 ]]; then
        read -p "Are you sure you want to delete all snapshots and backups? (y/N) " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || die "Abort."
    fi
    rm -f "$SNAP_DIR"/main_*.rs
    rm -f "$(dirname "$SOURCE_FILE")"/.*.bak.*
    success "Cleaned all snapshots and backups."
}

cmd_status() {
    printf "${C_BOLD}--- Workflow Status ---${C_RES}\n"
    printf "Project Root  : %s\n" "$(pwd)"
    printf "Source File   : %s (%s)\n" "$SOURCE_FILE" "$(get_sha256 "$SOURCE_FILE")"
    printf "Template File : %s (%s)\n" "$TEMPLATE_FILE" "$(get_sha256 "$TEMPLATE_FILE")"
    printf "Snapshots     : %s\n" "$(ls -1 "$SNAP_DIR"/main_*.rs 2>/dev/null | wc -l)"
    
    if [[ -d ".git" ]]; then
        printf "Git Branch    : %s\n" "$(git rev-parse --abbrev-ref HEAD)"
    fi
}

# --- CLI Boilerplate ---
show_help() {
    cat <<EOF
${C_BOLD}NCOPY v5 - The Toyota Programmer's Tool${C_RES}
Usage: $SCRIPT_NAME <command> [options]

Commands:
  run        Full cycle: Snapshot -> Backup -> Reset
  snapshot   Take a snapshot only
  reset      Reset source from template (mp.rs)
  rollback   Revert to latest backup
  latest     Show/Preview the newest snapshot
  list       List all snapshots
  status     Show project & file status
  clean      Delete snapshots and backups
  help       Show this help

Options:
  --fmt      Run 'cargo fmt' after reset
  --check    Run 'cargo check' after reset
  --dry-run  Show what would happen
  --force    Skip confirmation for 'clean'
  -v         Verbose output (previews in 'latest')

EOF
}

# --- Main Entry ---
[[ $# -lt 1 ]] && { show_help; exit 1; }
COMMAND="$1"; shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        --fmt) DO_FMT=1 ;;
        --check) DO_CHECK=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --force) FORCE=1 ;;
        -v) VERBOSE=1 ;;
        *) warn "Unknown option: $1" ;;
    esac
    shift
done

check_rust_env

case "$COMMAND" in
    run)      cmd_run ;;
    snapshot) create_snapshot "$SOURCE_FILE" ;;
    reset)    perform_reset ;;
    rollback) cmd_rollback ;;
    latest)   cmd_latest ;;
    status)   cmd_status ;;
    clean)    cmd_clean ;;
    list)     ls -lh "$SNAP_DIR"/main_*.rs 2>/dev/null || warn "No snapshots." ;;
    help)     show_help ;;
    *)        die "Unknown command: $COMMAND. Use 'help'." ;;
esac
