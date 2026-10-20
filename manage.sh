#!/usr/bin/env bash
set -Eeuo pipefail

# ArulKalvi PDF Library project manager
# Usage: ./manage.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$ROOT_DIR/.manage"
LOG_DIR="$STATE_DIR/logs"
DEV_PID_FILE="$STATE_DIR/dev.pid"
PROD_PID_FILE="$STATE_DIR/prod.pid"
BACKEND_PID_FILE="$STATE_DIR/backend.pid"
DEV_LOG="$LOG_DIR/dev.log"
PROD_LOG="$LOG_DIR/prod.log"
BACKEND_LOG="$LOG_DIR/backend.log"

mkdir -p "$LOG_DIR"
cd "$ROOT_DIR"

readonly RESET='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' BOLD='\033[1m'

info() { printf "${CYAN}%s${RESET}\n" "$*"; }
success() { printf "${GREEN}%s${RESET}\n" "$*"; }
warn() { printf "${YELLOW}%s${RESET}\n" "$*"; }
error() { printf "${RED}%s${RESET}\n" "$*" >&2; }
pause() { printf "\nPress Enter to continue..."; read -r; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

require_command() {
  if ! command_exists "$1"; then
    error "Required command not found: $1"
    return 1
  fi
}

read_pid() {
  local file="$1"
  [[ -f "$file" ]] && tr -d '[:space:]' < "$file" || true
}

pid_running() {
  local pid="${1:-}"
  [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}

cleanup_stale_pid() {
  local file="$1" pid
  pid="$(read_pid "$file")"
  if [[ -n "$pid" ]] && ! pid_running "$pid"; then
    rm -f "$file"
  fi
}

start_server() {
  local name="$1" pid_file="$2" log_file="$3"; shift 3
  cleanup_stale_pid "$pid_file"
  local old_pid
  old_pid="$(read_pid "$pid_file")"
  if pid_running "$old_pid"; then
    warn "$name is already running (PID $old_pid)."
    return 0
  fi

  : > "$log_file"
  nohup "$@" >>"$log_file" 2>&1 &
  local pid=$!
  echo "$pid" > "$pid_file"
  sleep 2
  if pid_running "$pid"; then
    success "$name started (PID $pid). Log: $log_file"
  else
    rm -f "$pid_file"
    error "$name failed to start. Check $log_file"
    return 1
  fi
}

stop_server() {
  local name="$1" pid_file="$2"
  local pid
  pid="$(read_pid "$pid_file")"
  if ! pid_running "$pid"; then
    rm -f "$pid_file"
    warn "$name is not running."
    return 0
  fi
  kill "$pid" 2>/dev/null || true
  for _ in {1..20}; do
    pid_running "$pid" || break
    sleep 0.25
  done
  if pid_running "$pid"; then
    warn "$name did not stop gracefully; sending SIGKILL."
    kill -9 "$pid" 2>/dev/null || true
  fi
  rm -f "$pid_file"
  success "$name stopped."
}

ensure_node_dependencies() {
  if [[ ! -d "$ROOT_DIR/node_modules" ]]; then
    warn "node_modules is missing; installing dependencies..."
    require_command npm
    npm install
  fi
}

build_project() {
  ensure_node_dependencies
  if ! npm run build; then
    error "Project build failed. Review the Vite output above."
    return 1
  fi
  success "Project build completed."
}

rebuild_project() {
  warn "Starting a clean rebuild..."
  stop_prod || true
  stop_backend || true
  if [[ -d "$ROOT_DIR/dist" ]]; then
    rm -rf "$ROOT_DIR/dist"
  fi
  require_command npm
  npm install
  build_project
  success "Clean rebuild completed."
}

start_dev() {
  ensure_node_dependencies
  start_server "Development server" "$DEV_PID_FILE" "$DEV_LOG" npm run dev -- --host 0.0.0.0
  info "Open http://localhost:5173"
}

stop_dev() { stop_server "Development server" "$DEV_PID_FILE"; }

start_frontend() {
  ensure_node_dependencies
  start_server "Frontend development server" "$DEV_PID_FILE" "$DEV_LOG" npm run dev -- --host 0.0.0.0
  info "Frontend: http://localhost:5173"
}

stop_frontend() { stop_server "Frontend development server" "$DEV_PID_FILE"; }

start_backend() {
  ensure_node_dependencies
  require_command npx
  [[ -d "$ROOT_DIR/dist" ]] || build_project
  start_server "Backend Pages Functions server" "$BACKEND_PID_FILE" "$BACKEND_LOG" npx wrangler pages dev dist --ip 0.0.0.0 --port 8788
  info "Backend/API: http://localhost:8788"
}

stop_backend() { stop_server "Backend Pages Functions server" "$BACKEND_PID_FILE"; }

start_prod() {
  ensure_node_dependencies
  [[ -d "$ROOT_DIR/dist" ]] || build_project
  start_server "Production preview" "$PROD_PID_FILE" "$PROD_LOG" npm run preview -- --host 0.0.0.0
  info "Open http://localhost:4173"
}

stop_prod() { stop_server "Production preview" "$PROD_PID_FILE"; }

require_supabase() {
  require_command supabase || { error "Install Supabase CLI: https://supabase.com/docs/guides/cli"; return 1; }
}

setup_database() {
  require_supabase
  if [[ ! -d "$ROOT_DIR/supabase" ]]; then
    info "Initializing local Supabase project..."
    supabase init
  else
    warn "Supabase project is already initialized."
  fi
  supabase start
  success "Database setup completed."
}

run_migration() {
  require_supabase
  if [[ -n "${SUPABASE_DB_URL:-}" ]]; then
    info "Pushing migrations to SUPABASE_DB_URL..."
    supabase db push --db-url "$SUPABASE_DB_URL"
  else
    info "Applying migrations to the linked Supabase project..."
    supabase db push
  fi
  success "Database migration completed."
}

database_status() {
  require_supabase
  info "Supabase local status:"
  supabase status || true
  printf "\n"
  info "Migration status:"
  if [[ -n "${SUPABASE_DB_URL:-}" ]]; then
    supabase migration list --db-url "$SUPABASE_DB_URL" || true
  else
    supabase migration list || true
  fi
}

clean_database() {
  require_supabase
  warn "This removes local Supabase database data and resets local migrations."
  printf "Type RESET DATABASE to continue: "
  read -r confirmation
  [[ "$confirmation" == "RESET DATABASE" ]] || { warn "Cancelled."; return 0; }
  supabase db reset
  success "Local database reset completed."
}

pull_latest() {
  require_command git
  if [[ -n "$(git status --porcelain)" ]]; then
    warn "Working tree has uncommitted changes. Pull is paused for safety."
    git status --short
    return 1
  fi
  git pull --ff-only
  success "Latest changes pulled."
}

show_menu() {
  clear 2>/dev/null || true
  printf "${BOLD}${CYAN}ArulKalvi PDF Library - Project Manager${RESET}\n\n"
  printf "  ${BOLD}1${RESET}) Build project\n"
  printf "  ${BOLD}2${RESET}) Start frontend\n"
  printf "  ${BOLD}3${RESET}) Stop frontend\n"
  printf "  ${BOLD}4${RESET}) Start backend\n"
  printf "  ${BOLD}5${RESET}) Stop backend\n"
  printf "  ${BOLD}6${RESET}) Start production preview\n"
  printf "  ${BOLD}7${RESET}) Stop production preview\n"
  printf "  ${BOLD}8${RESET}) Clean database (local, destructive)\n"
  printf "  ${BOLD}9${RESET}) Setup database (initialize/start Supabase)\n"
  printf "  ${BOLD}10${RESET}) Run database migration\n"
  printf "  ${BOLD}11${RESET}) Database status\n"
  printf "  ${BOLD}12${RESET}) Pull latest changes\n"
  printf "  ${BOLD}13${RESET}) Clean rebuild project\n"
  printf "  ${BOLD}0${RESET}) Exit\n\n"
}

main() {
  while true; do
    show_menu
    read -rp "Select an option: " choice
    printf "\n"
    case "$choice" in
      1) build_project || true; pause ;;
      2) start_frontend || true; pause ;;
      3) stop_frontend || true; pause ;;
      4) start_backend || true; pause ;;
      5) stop_backend || true; pause ;;
      6) start_prod || true; pause ;;
      7) stop_prod || true; pause ;;
      8) clean_database || true; pause ;;
      9) setup_database || true; pause ;;
      10) run_migration || true; pause ;;
      11) database_status || true; pause ;;
      12) pull_latest || true; pause ;;
      13) rebuild_project || true; pause ;;
      0) info "Goodbye."; exit 0 ;;
      *) error "Invalid option. Choose one of the numbered options."; sleep 1 ;;
    esac
  done
}

trap 'error "Unexpected error on line $LINENO. Check the command output above."' ERR
main "$@"
