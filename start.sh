#!/usr/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh

gh auth login

mkdir -p $HOME/code
cd $HOME/code

gh repo clone RomainBoulay/terminal
cd terminal/
./install-ubuntu.sh
