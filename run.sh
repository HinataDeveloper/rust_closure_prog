#!/usr/bin/env bash
set -euo pipefail

# =========================
# Colors (disable by NO_COLOR=1)
# =========================
if [[ "${NO_COLOR:-0}" == "1" ]]; then
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
else
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  NC='\033[0m'
fi

# =========================
# Logging helpers
# =========================
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
die()     { error "$*"; exit 1; }

# =========================
# Checks
# =========================
require_file() {
  local file="$1"
  [[ -f "$file" ]] || die "File not found: $file (run this in your Rust project root)"
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
}

# =========================
# Project detection
# =========================
get_project_name() {
  # Extract [package].name from Cargo.toml
  awk -F '"' '
    /^\[package\]/ { in_package=1; next }
    /^\[/ && !/^\[package\]/ { in_package=0 }
    in_package && /^name[[:space:]]*=/ { print $2; exit }
  ' Cargo.toml
}

# =========================
# Help
# =========================
show_help() {
  cat <<'EOF'
Usage:
  ./run.sh <command> [options] [-- program_args...]

Commands:
  fix         Run cargo fix (safe default: allow dirty)
  check       Run cargo check
  build       Run cargo build (dev)
  run         Run project (dev). Pass args after -- or directly.
  release     Run project (release). Pass args after -- or directly.
  test        Run cargo test
  clean       Run cargo clean
  fmt         Run cargo fmt
  clippy      Run cargo clippy
  all         Run fix + fmt + clippy + test + run (dev)

Common options (for run/release):
  --bin <name>        Choose a specific binary (for multi-bin projects)
  --package <name>    Choose a specific package (workspace). Default: auto from Cargo.toml
  --no-clear          Don't clear terminal
  --no-color          Disable colored output (same as NO_COLOR=1)

Examples:
  ./run.sh check
  ./run.sh run
  ./run.sh run hello 123
  ./run.sh run -- --flag value
  ./run.sh run --bin server -- --port 8080
  ./run.sh release --bin cli -- input.txt
  NO_COLOR=1 ./run.sh all

Notes:
- If your project has multiple binaries, prefer: ./run.sh run --bin <binname>
- For passing arguments to your Rust program, using `--` is the safest.
EOF
}

# =========================
# Argument parsing (lightweight)
# =========================
COMMAND="${1:-help}"
shift || true

NO_CLEAR=0
BIN_NAME=""
PACKAGE_NAME=""

# Parse options (only for commands that support them; harmless otherwise)
# We accept:
#   --bin NAME
#   --package NAME
#   --no-clear
#   --no-color
# and allow `--` to stop parsing and pass the rest to program args.
PROGRAM_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bin)
      [[ $# -ge 2 ]] || die "--bin requires a value"
      BIN_NAME="$2"
      shift 2
      ;;
    --package)
      [[ $# -ge 2 ]] || die "--package requires a value"
      PACKAGE_NAME="$2"
      shift 2
      ;;
    --no-clear)
      NO_CLEAR=1
      shift
      ;;
    --no-color)
      # disable colors on the fly
      RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
      shift
      ;;
    --help|-h)
      COMMAND="help"
      shift
      ;;
    --)
      shift
      PROGRAM_ARGS+=("$@")
      break
      ;;
    *)
      # For run/release, treat remaining as program args (convenient mode)
      PROGRAM_ARGS+=("$1")
      shift
      ;;
  esac
done

# =========================
# Setup
# =========================
require_command cargo
require_file Cargo.toml

AUTO_PROJECT_NAME="$(get_project_name || true)"
[[ -n "${AUTO_PROJECT_NAME:-}" ]] || die "Could not extract [package].name from Cargo.toml"

if [[ -z "${PACKAGE_NAME:-}" ]]; then
  PACKAGE_NAME="$AUTO_PROJECT_NAME"
fi

if [[ "$NO_CLEAR" -eq 0 ]]; then
  clear || true
fi

info "Project: ${CYAN}${AUTO_PROJECT_NAME}${NC}"
info "Package: ${CYAN}${PACKAGE_NAME}${NC}"
if [[ -n "${BIN_NAME:-}" ]]; then
  info "Bin:     ${CYAN}${BIN_NAME}${NC}"
fi

# Build common cargo args
CARGO_SEL_ARGS=(--package "$PACKAGE_NAME")
if [[ -n "${BIN_NAME:-}" ]]; then
  CARGO_SEL_ARGS+=(--bin "$BIN_NAME")
fi

# =========================
# Command implementations
# =========================
cmd_fix() {
  info "Running: cargo fix"
  cargo fix --allow-dirty
  success "cargo fix done"
}

cmd_check() {
  info "Running: cargo check"
  cargo check
  success "cargo check done"
}

cmd_build() {
  info "Running: cargo build"
  cargo build
  success "cargo build done"
}

cmd_run() {
  info "Running: cargo run (dev)"
  # Note: For multi-bin packages, --bin matters; for single-bin it's optional.
  cargo run --color=always "${CARGO_SEL_ARGS[@]}" --profile dev -- "${PROGRAM_ARGS[@]}"
  success "cargo run done"
}

cmd_release() {
  info "Running: cargo run (release)"
  cargo run --color=always "${CARGO_SEL_ARGS[@]}" --release -- "${PROGRAM_ARGS[@]}"
  success "release run done"
}

cmd_test() {
  info "Running: cargo test"
  cargo test
  success "cargo test done"
}

cmd_clean() {
  info "Running: cargo clean"
  cargo clean
  success "cargo clean done"
}

cmd_fmt() {
  require_command cargo-fmt || true
  info "Running: cargo fmt"
  cargo fmt
  success "cargo fmt done"
}

cmd_clippy() {
  require_command cargo-clippy || true
  info "Running: cargo clippy"
  cargo clippy -- -D warnings
  success "cargo clippy done"
}

cmd_all() {
  # ترتیب پیشنهادی: fmt -> fix -> clippy -> test -> run
  cmd_fmt
  cmd_fix
  cmd_clippy
  cmd_test
  cmd_run
}

# =========================
# Dispatch
# =========================
case "$COMMAND" in
  fix)     cmd_fix ;;
  check)   cmd_check ;;
  build)   cmd_build ;;
  run)     cmd_run ;;
  release) cmd_release ;;
  test)    cmd_test ;;
  clean)   cmd_clean ;;
  fmt)     cmd_fmt ;;
  clippy)  cmd_clippy ;;
  all)     cmd_all ;;
  help|--help|-h|"") show_help ;;
  *)
    error "Unknown command: $COMMAND"
    echo
    show_help
    exit 2
    ;;
esac
