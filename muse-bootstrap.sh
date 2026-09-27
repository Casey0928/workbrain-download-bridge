#!/usr/bin/env bash
set -euo pipefail

RECOVERY_REPO="Casey0928/wechat-codespace"
RECOVERY_BRANCH="muse-recovery"
RECOVERY_SUBDIR="muse-recovery"
TARGET="${MUSE_RECOVERY_SOURCE:-${HOME:-/home/hatch}/muse-recovery-src}"

log() { printf '[muse-bootstrap] %s\n' "$*"; }
die() { printf '[muse-bootstrap] ERROR: %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
  die "Run this bootstrap as root inside the Muse runtime."
fi

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1
}

if ! ensure_cmd curl || ! ensure_cmd git; then
  log "Installing curl/git..."
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl git ca-certificates
fi

if ! ensure_cmd gh; then
  log "Installing GitHub CLI..."
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y gh
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  log "GitHub authentication is required once to access the private recovery repository."
  log "A browser/device authorization step will open or print a code."
  gh auth login --hostname github.com --git-protocol https --web
fi

log "GitHub authenticated."

if [ -d "$TARGET/.git" ]; then
  log "Updating existing recovery checkout..."
  git -C "$TARGET" fetch origin "$RECOVERY_BRANCH"
  git -C "$TARGET" checkout "$RECOVERY_BRANCH"
  git -C "$TARGET" reset --hard "origin/$RECOVERY_BRANCH"
else
  rm -rf "$TARGET"
  log "Cloning private recovery branch..."
  gh repo clone "$RECOVERY_REPO" "$TARGET" -- --branch "$RECOVERY_BRANCH" --single-branch
fi

INSTALLER="$TARGET/$RECOVERY_SUBDIR/install.sh"
[ -f "$INSTALLER" ] || die "Installer not found: $INSTALLER"

log "Running Muse recovery installer..."
exec bash "$INSTALLER"
