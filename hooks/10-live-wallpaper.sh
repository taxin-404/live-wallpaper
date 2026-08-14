#!/usr/bin/env bash
# Restore the active live wallpaper after a theme change. Omarchy restarts the
# shell and resets the background to the new theme's image, which would cover
# the live wallpaper. Give it a moment, then relaunch.
set -euo pipefail

sleep 1
omarchy-live-wallpaper restore >/dev/null 2>&1 || true