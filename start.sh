#!/usr/bin/env bash
set -euo pipefail

# --- 1. Homebrew (macOS or Linuxbrew) ----------------------------------
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  exec "$SHELL" -l
fi

# --- 2. gh + clone terminal repo ---------------------------------------
brew install gh
gh auth login

if [[ "$(uname -s)" == "Darwin" ]]; then
  default_dir="$HOME/Developer"
else
  default_dir="$HOME/code"
fi

read -r -p "Folder for the terminal repo [$default_dir]: " repo_dir
repo_dir="${repo_dir:-$default_dir}"
repo_dir="${repo_dir/#\~/$HOME}"

mkdir -p "$repo_dir"
cd "$repo_dir"

gh repo clone RomainBoulay/terminal || true
cd terminal/

# --- 3. Per-OS installer --------
./install.sh
