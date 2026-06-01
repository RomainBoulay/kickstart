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

mkdir -p "$HOME/code"
cd "$HOME/code"

gh repo clone RomainBoulay/terminal || true
cd terminal/

REPO_DIR="$PWD"

# --- 3. chezmoi + dcli bootstrap ---------------------------------------
# Installs the tooling and writes the chezmoi source-dir config so that
# `chezmoi apply` can be run manually after `dcli sync`. We don't apply
# automatically — see chezmoi/MIGRATION.md (secrets must exist in
# Dashlane and dcli must be unlocked first).
if [[ -d "$REPO_DIR/chezmoi" ]]; then
  echo "==================== chezmoi bootstrap ===================="

  brew install chezmoi
  brew install dashlane/tap/dashlane-cli

  mkdir -p "$HOME/.config/chezmoi"
  cat >"$HOME/.config/chezmoi/chezmoi.toml" <<EOF
sourceDir = "$REPO_DIR/chezmoi"
EOF
  echo "wrote $HOME/.config/chezmoi/chezmoi.toml"

  cat <<'NEXT'

chezmoi + dcli installed. To finish the migration:

  1. Populate Dashlane entries (see chezmoi/MIGRATION.md)
  2. dcli sync
  3. bash chezmoi/scripts/verify-dashlane-entries.sh
  4. chezmoi diff      # preview
  5. chezmoi apply     # materialize ~/.zshrc, ~/.gitconfig, ~/.ssh/*, ~/.config/compose/.env

NEXT
fi

# --- 4. Legacy per-OS installer ----------------------------------------
case "$(uname -s)" in
  Darwin)
    ./install-macOS.sh
    ;;
  Linux)
    ./install-ubuntu.sh
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
