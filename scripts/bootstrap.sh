#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Bootstrap script for this dotfiles repository (Ubuntu only).
# Workflow:
#   1) git clone <dotfiles-repo>
#   2) cd <dotfiles-repo>/scripts
#   3) ./bootstrap.sh
# -----------------------------------------------------------------------------

# ---- Runtime metadata --------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_FILE="$HOME/bootstrap.log"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"

CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"

OS=""
SUDO_CMD=""
FONT_DIR=""
APT_UPDATED=0
BACKUP_DIR=""

# ---- Summary tracking --------------------------------------------------------
declare -a INSTALLED_ITEMS=()
declare -a SKIPPED_ITEMS=()
declare -a FAILED_ITEMS=()
declare -a NEXT_STEPS=()

# ---- Logging setup -----------------------------------------------------------
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---- Logging helpers ---------------------------------------------------------
log() {
  local level="$1"
  shift
  printf '[%s] %s\n' "$level" "$*"
}

info() { log "INFO" "$*"; }

mark_installed() {
  INSTALLED_ITEMS+=("$1")
  log "INSTALLED" "$1"
}

mark_skipped() {
  local item="$1"
  local reason="${2:-already configured}"
  SKIPPED_ITEMS+=("$item")
  log "SKIPPED" "$item ($reason)"
}

mark_failed() {
  local item="$1"
  local reason="${2:-failed}"
  FAILED_ITEMS+=("$item")
  log "FAILED" "$item ($reason)"
}

# ---- Utility helpers ---------------------------------------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

command_exists_any() {
  local cmd
  for cmd in "$@"; do
    if command_exists "$cmd"; then
      return 0
    fi
  done
  return 1
}

node_runtime_exists() {
  command_exists node || command_exists nodejs
}

ensure_node_command_alias() {
  if command_exists node; then
    return
  fi

  if command_exists nodejs; then
    ln -sf "$(command -v nodejs)" "$LOCAL_BIN_DIR/node"
    export PATH="$LOCAL_BIN_DIR:$PATH"
    hash -r
    info "Created node shim: $LOCAL_BIN_DIR/node -> $(command -v nodejs)"
  fi
}

run_privileged() {
  if [[ -n "$SUDO_CMD" ]]; then
    "$SUDO_CMD" "$@"
  else
    "$@"
  fi
}

canonical_path() {
  local path="$1"
  if command_exists realpath; then
    realpath "$path"
  elif command_exists perl; then
    perl -MCwd=abs_path -e 'my $p = abs_path(shift); exit($p ? 0 : 1); print $p;' "$path"
  else
    return 1
  fi
}

ensure_backup_dir() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$CONFIG_DIR/backup/$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    info "Created backup directory: $BACKUP_DIR"
  fi
}

backup_target() {
  local target="$1"
  local base_name
  local backup_path

  ensure_backup_dir
  base_name="$(basename "$target")"
  backup_path="$BACKUP_DIR/$base_name"

  if [[ -e "$backup_path" || -L "$backup_path" ]]; then
    backup_path="$BACKUP_DIR/${base_name}.$(date +%s)"
  fi

  mv "$target" "$backup_path"
  info "Backed up $target -> $backup_path"
}

paths_match() {
  local path_a="$1"
  local path_b="$2"
  local resolved_a
  local resolved_b

  resolved_a="$(canonical_path "$path_a" 2>/dev/null || true)"
  resolved_b="$(canonical_path "$path_b" 2>/dev/null || true)"

  [[ -n "$resolved_a" && -n "$resolved_b" && "$resolved_a" == "$resolved_b" ]]
}

# ---- Environment detection ---------------------------------------------------
detect_environment() {
  info "Detecting Ubuntu environment..."

  case "$(uname -s)" in
    Linux)
      OS="linux"

      if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
      fi

      local distro_id="${ID:-unknown}"
      local distro_like="${ID_LIKE:-}"

      if [[ "$distro_id" != "ubuntu" && "$distro_like" != *ubuntu* ]]; then
        mark_failed "OS detection" "unsupported Linux distro: $distro_id"
        printf 'This script currently supports Ubuntu only.\n'
        printf 'Use Ubuntu or extend this script for your distro.\n'
        exit 1
      fi

      if ! command_exists apt-get; then
        mark_failed "Package manager detection" "apt-get not found"
        printf 'apt-get was not found. This script requires Ubuntu apt.\n'
        exit 1
      fi

      FONT_DIR="$HOME/.local/share/fonts"

      if [[ "$EUID" -eq 0 ]]; then
        SUDO_CMD=""
      elif command_exists sudo; then
        SUDO_CMD="sudo"
      else
        mark_failed "Privilege check" "sudo is required for apt installs"
        printf 'Install sudo or run this script as root to use apt installs.\n'
        exit 1
      fi
      ;;

    *)
      mark_failed "OS detection" "unsupported OS: $(uname -s)"
      printf 'Unsupported OS. This script supports Ubuntu only.\n'
      exit 1
      ;;
  esac

  info "Detected environment: OS=$OS (Ubuntu/apt)"
}

# ---- Package manager wrappers ------------------------------------------------
apt_install_packages() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    info "Running apt-get update..."
    if ! run_privileged apt-get update; then
      return 1
    fi
    APT_UPDATED=1
  fi

  run_privileged apt-get install -y "$@"
}

install_package() {
  apt_install_packages "$@"
}

# ---- Path/bootstrap hygiene --------------------------------------------------
ensure_core_dirs() {
  info "Ensuring required directories exist..."
  mkdir -p "$CONFIG_DIR"
  mkdir -p "$LOCAL_BIN_DIR"
  mkdir -p "$FONT_DIR"

  # Ensure this bootstrap process itself can find binaries installed to ~/.local/bin.
  export PATH="$LOCAL_BIN_DIR:$PATH"
}

rc_contains_local_bin_path() {
  local rc_file="$1"
  grep -Eq '(^|[[:space:]])(export[[:space:]]+PATH=.*(\$HOME|~)/\.local/bin|PATH=.*(\$HOME|~)/\.local/bin)' "$rc_file"
}

ensure_local_bin_path_block() {
  local rc_file="$1"
  local rc_label
  local marker_start="# >>> dotfiles-bootstrap local-bin >>>"

  rc_label="$(basename "$rc_file")"
  touch "$rc_file"

  if grep -Fq "$marker_start" "$rc_file"; then
    mark_skipped "PATH guard in $rc_label" "already present"
    return
  fi

  if rc_contains_local_bin_path "$rc_file"; then
    mark_skipped "PATH guard in $rc_label" "PATH already configured"
    return
  fi

  cat >>"$rc_file" <<'BLOCK'

# >>> dotfiles-bootstrap local-bin >>>
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi
# <<< dotfiles-bootstrap local-bin <<<
BLOCK

  mark_installed "PATH guard in $rc_label"
}

ensure_shell_path_setup() {
  info "Ensuring ~/.local/bin is persisted in shell startup files..."
  ensure_local_bin_path_block "$HOME/.bashrc"
  ensure_local_bin_path_block "$HOME/.zshrc"
}

# ---- Tool installation -------------------------------------------------------
install_nodejs_and_npm() {
  local item="nodejs + npm"

  if node_runtime_exists && command_exists npm; then
    ensure_node_command_alias
    mark_skipped "$item" "already installed"
    return
  fi

  info "Installing $item..."
  if install_package nodejs npm; then
    ensure_node_command_alias
    hash -r
    if node_runtime_exists && command_exists npm; then
      mark_installed "$item"
    else
      mark_failed "$item" "install finished but commands not found"
    fi
  else
    mark_failed "$item" "apt install failed"
  fi
}

jetbrains_font_installed() {
  local found
  found="$(find "$FONT_DIR" -maxdepth 1 -type f \( -iname '*JetBrains*Nerd*' -o -iname 'JetBrainsMonoNerdFont*' \) -print -quit 2>/dev/null || true)"
  [[ -n "$found" ]]
}

refresh_font_cache() {
  if command_exists fc-cache; then
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1 || true
  fi
}

install_jetbrains_nerd_font() {
  local item="JetBrains Nerd Font"
  local tmp_dir=""
  local zip_file=""
  local font_extract_dir=""

  if jetbrains_font_installed; then
    mark_skipped "$item" "already installed"
    return
  fi

  if ! command_exists curl; then
    mark_failed "$item" "curl is required"
    return
  fi

  if ! command_exists unzip; then
    info "'unzip' not found, installing dependency..."
    if ! install_package unzip; then
      mark_failed "$item" "failed to install unzip"
      return
    fi
  fi

  info "Installing $item..."
  tmp_dir="$(mktemp -d)"
  zip_file="$tmp_dir/JetBrainsMono.zip"
  font_extract_dir="$tmp_dir/fonts"

  if curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$zip_file" && \
     unzip -oq "$zip_file" -d "$font_extract_dir"; then
    local copied=0
    while IFS= read -r font_file; do
      cp -f "$font_file" "$FONT_DIR/"
      copied=1
    done < <(find "$font_extract_dir" -type f -name '*.ttf')

    if [[ "$copied" -eq 1 ]]; then
      refresh_font_cache
      mark_installed "$item"
    else
      mark_failed "$item" "no .ttf files found in archive"
    fi
  else
    mark_failed "$item" "download or extraction failed"
  fi

  rm -rf "$tmp_dir"
}

install_opencode() {
  local item="opencode"

  if command_exists opencode; then
    mark_skipped "$item" "already installed"
    return
  fi

  if ! command_exists curl; then
    mark_failed "$item" "curl is required"
    return
  fi

  info "Installing $item..."
  if curl -fsSL https://opencode.ai/install | bash; then
    hash -r
    if command_exists opencode; then
      mark_installed "$item"
    else
      mark_failed "$item" "installer completed but binary not found"
    fi
  else
    mark_failed "$item" "install command failed"
  fi
}

install_github_copilot_cli() {
  local item="GitHub Copilot CLI"

  if command_exists_any github-copilot copilot; then
    mark_skipped "$item" "already installed"
    NEXT_STEPS+=("GitHub Copilot auth: github-copilot auth login")
    return
  fi

  if ! command_exists npm; then
    mark_failed "$item" "npm is required"
    return
  fi

  info "Installing $item..."
  if npm install -g @github/copilot --prefix "$HOME/.local"; then
    hash -r
    if command_exists_any github-copilot copilot; then
      mark_installed "$item"
      NEXT_STEPS+=("GitHub Copilot auth: github-copilot auth login")
    else
      mark_failed "$item" "install finished but command not found"
    fi
  else
    mark_failed "$item" "npm global install failed"
  fi
}

install_codex_cli() {
  local item="codex"

  if command_exists codex; then
    mark_skipped "$item" "already installed"
    NEXT_STEPS+=("Codex auth (if needed): codex login")
    return
  fi

  if ! command_exists npm; then
    mark_failed "$item" "npm is required"
    return
  fi

  info "Installing $item..."
  if npm i -g @openai/codex --prefix "$HOME/.local"; then
    hash -r
    if command_exists codex; then
      mark_installed "$item"
      NEXT_STEPS+=("Codex auth (if needed): codex login")
    else
      mark_failed "$item" "install finished but command not found"
    fi
  else
    mark_failed "$item" "npm global install failed"
  fi
}

install_neovim() {
  local item="neovim"

  if command_exists nvim; then
    mark_skipped "$item" "already installed"
    return
  fi

  info "Installing $item..."
  if install_package neovim; then
    hash -r
    if command_exists nvim; then
      mark_installed "$item"
    else
      mark_failed "$item" "install finished but command not found"
    fi
  else
    mark_failed "$item" "package install failed"
  fi
}

bash_completion_available() {
  [[ -f /usr/share/bash-completion/bash_completion || -f /etc/bash_completion ]]
}

install_shell_suggestion_tools() {
  local item="bash suggestions (bash-completion + fzf)"

  if command_exists fzf && bash_completion_available; then
    mark_skipped "$item" "already installed"
    return
  fi

  info "Installing $item..."
  if install_package bash-completion fzf; then
    hash -r
    if command_exists fzf && bash_completion_available; then
      mark_installed "$item"
    else
      mark_failed "$item" "install finished but tools not detected"
    fi
  else
    mark_failed "$item" "package install failed"
  fi
}

install_oh_my_posh() {
  local item="oh-my-posh"

  if command_exists oh-my-posh; then
    mark_skipped "$item" "already installed"
    return
  fi

  info "Installing $item..."

  # Linux apt path first; fallback to the official installer if package is unavailable.
  if install_package oh-my-posh; then
    hash -r
    if command_exists oh-my-posh; then
      mark_installed "$item"
      return
    fi
  fi

  if command_exists curl && curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$LOCAL_BIN_DIR"; then
    hash -r
    if command_exists oh-my-posh; then
      mark_installed "$item"
    else
      mark_failed "$item" "fallback installer finished but command not found"
    fi
  else
    mark_failed "$item" "apt and fallback installer failed"
  fi
}

install_tmux() {
  local item="tmux"

  if command_exists tmux; then
    mark_skipped "$item" "already installed"
    return
  fi

  info "Installing $item..."
  if install_package tmux; then
    hash -r
    if command_exists tmux; then
      mark_installed "$item"
    else
      mark_failed "$item" "install finished but command not found"
    fi
  else
    mark_failed "$item" "package install failed"
  fi
}

# ---- Symlink management ------------------------------------------------------
link_source_to_target() {
  local source="$1"
  local target="$2"
  local item="$3"

  if [[ ! -e "$source" && ! -L "$source" ]]; then
    mark_failed "$item" "source missing: $source"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    if paths_match "$target" "$source"; then
      mark_skipped "$item" "already linked correctly"
      return
    fi

    if ! backup_target "$target"; then
      mark_failed "$item" "failed to back up existing symlink"
      return
    fi
  elif [[ -e "$target" ]]; then
    if ! backup_target "$target"; then
      mark_failed "$item" "failed to back up existing target"
      return
    fi
  fi

  if ln -s "$source" "$target"; then
    mark_installed "$item"
  else
    mark_failed "$item" "failed to create symlink"
  fi
}

link_repo_managed_configs() {
  info "Linking repo-managed configuration files/directories..."

  # Explicit mapping required for this repo. Add new managed paths here.
  local -a mappings=(
    "$REPO_ROOT/nvim|$HOME/.config/nvim|symlink: nvim"
    "$REPO_ROOT/.config/tmux|$HOME/.config/tmux|symlink: tmux"
    "$REPO_ROOT/oh-my-posh|$HOME/.config/oh-my-posh|symlink: oh-my-posh"
    "$REPO_ROOT/opencode|$HOME/.config/opencode|symlink: opencode"
    "$REPO_ROOT/.bashrc|$HOME/.bashrc|symlink: .bashrc"
  )

  local mapping
  local source
  local target
  local label

  for mapping in "${mappings[@]}"; do
    IFS='|' read -r source target label <<<"$mapping"

    if [[ -e "$source" || -L "$source" ]]; then
      link_source_to_target "$source" "$target" "$label"
    else
      mark_skipped "$label" "source not present in repo"
    fi
  done
}

# ---- Final summary -----------------------------------------------------------
print_summary() {
  echo
  info "Bootstrap complete. Log file: $LOG_FILE"

  printf 'Installed (%d):\n' "${#INSTALLED_ITEMS[@]}"
  if [[ "${#INSTALLED_ITEMS[@]}" -eq 0 ]]; then
    printf '  - none\n'
  else
    local item
    for item in "${INSTALLED_ITEMS[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  printf 'Skipped (%d):\n' "${#SKIPPED_ITEMS[@]}"
  if [[ "${#SKIPPED_ITEMS[@]}" -eq 0 ]]; then
    printf '  - none\n'
  else
    local item
    for item in "${SKIPPED_ITEMS[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  printf 'Failed (%d):\n' "${#FAILED_ITEMS[@]}"
  if [[ "${#FAILED_ITEMS[@]}" -eq 0 ]]; then
    printf '  - none\n'
  else
    local item
    for item in "${FAILED_ITEMS[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  if [[ -n "$BACKUP_DIR" ]]; then
    printf 'Backup directory: %s\n' "$BACKUP_DIR"
  fi

  if [[ "${#NEXT_STEPS[@]}" -gt 0 ]]; then
    echo
    printf 'Next steps (auth may be required):\n'
    local step
    for step in "${NEXT_STEPS[@]}"; do
      printf '  - %s\n' "$step"
    done
  fi

  if [[ "${#FAILED_ITEMS[@]}" -gt 0 ]]; then
    exit 1
  fi
}

# ---- Main flow ---------------------------------------------------------------
main() {
  info "Starting bootstrap at $(date '+%Y-%m-%d %H:%M:%S')"
  info "Repo root: $REPO_ROOT"

  detect_environment
  ensure_core_dirs

  install_nodejs_and_npm
  install_jetbrains_nerd_font
  install_opencode
  install_github_copilot_cli
  install_codex_cli
  install_neovim
  install_shell_suggestion_tools
  install_oh_my_posh
  install_tmux

  link_repo_managed_configs
  ensure_shell_path_setup

  print_summary
}

main "$@"
