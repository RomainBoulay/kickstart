#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  exec "$SHELL" -l
fi

brew install gh

gh auth login

mkdir -p "$HOME/code"
cd "$HOME/code"

gh repo clone RomainBoulay/terminal || true
cd terminal/

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
