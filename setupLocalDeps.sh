#!/bin/bash
# Install Avidemux build dependencies into a project-local Homebrew prefix.
# This keeps your system Homebrew clean.
#
# Usage:
#   bash setupLocalDeps.sh [path]
#
# Default path: <repo>/.local-deps/brew
#
# Then build with:
#   bash bootStrapMacOS_Tahoe.arm64.sh --local-deps=<path>
#
# ARM64 note: Homebrew bottles are compiled for /opt/homebrew. Using a
# different prefix means most packages build from source — expect 30-90 min.

set -e

SRCTOP=$(cd "$(dirname "$0")" && pwd)
DEFAULT_DEPS="${SRCTOP}/.local-deps/brew"
BREW_DIR="${1:-$DEFAULT_DEPS}"

if [[ "$BREW_DIR" = *" "* ]]; then
    echo "Error: path \"$BREW_DIR\" contains spaces. Choose a path without spaces."
    exit 1
fi

if [ -d "$BREW_DIR/.git" ] || [ -f "$BREW_DIR/bin/brew" ]; then
    echo "Homebrew already present at $BREW_DIR"
else
    echo "Cloning Homebrew to $BREW_DIR ..."
    mkdir -p "$(dirname "$BREW_DIR")"
    git clone --depth=1 https://github.com/Homebrew/brew.git "$BREW_DIR"
fi

export HOMEBREW_PREFIX="$BREW_DIR"
export HOMEBREW_CELLAR="${BREW_DIR}/Cellar"
export HOMEBREW_REPOSITORY="$BREW_DIR"
export PATH="${BREW_DIR}/bin:${BREW_DIR}/sbin:$PATH"

echo "Updating Homebrew..."
brew update --quiet

echo "Installing dependencies..."
brew install \
    cmake pkg-config nasm yasm \
    qt@6 \
    xvid x264 x265 libvpx aom \
    opus fdk-aac lame libass \
    mp4v2 a52dec

echo ""
echo "** Done. **"
echo ""
echo "Build Avidemux with local deps:"
echo "  bash bootStrapMacOS_Tahoe.arm64.sh --local-deps=\"${BREW_DIR}\""
