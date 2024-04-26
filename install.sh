#!/bin/sh
# This script installs Ollama on Linux in the user's home bin directory without root access.

set -eu

status() { echo ">>> $*" >&2; }
error() { echo "ERROR: $*" >&2; exit 1; }
warning() { echo "WARNING: $*" >&2; }

# Detect OS and architecture
[ "$(uname -s)" = "Linux" ] || error 'This script is intended to run on Linux only.'
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

# Define the temp directory and ensure it gets cleaned up
TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# Check necessary commands are available
command -v curl >/dev/null || error "curl is required but not installed."

status "Downloading Ollama..."
curl --fail --show-error --location --progress-bar -o "$TEMP_DIR/ollama" "https://ollama.com/download/ollama-linux-$ARCH"

# Set the installation directory to ~/bin
BINDIR="$HOME/bin"
mkdir -p "$BINDIR"

status "Installing Ollama to $BINDIR..."
mv "$TEMP_DIR/ollama" "$BINDIR/ollama"
chmod +x "$BINDIR/ollama"

status 'Install complete. Run "ollama" from the command line.'

# Add $HOME/bin to PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/bin"; then
  echo "export PATH=\"$HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
  status 'Added ~/bin to PATH in .bashrc'
fi