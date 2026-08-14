#!/usr/bin/env bash
# taxin.live-wallpaper — uninstaller.
#
# Removes the menu override, the theme-set hook, and the CLI symlinks, then
# stops any running live wallpaper and clears its state. The plugin folder
# itself is left in place so the shell stops loading it once removed.
set -euo pipefail

echo "--- taxin.live-wallpaper :: uninstaller ---"

# 1. Remove the menu override block (reverts style.background to the stock
#    static-only switcher).
MENU_EXT="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
if [[ -f $MENU_EXT ]]; then
  sed -i '/\/\/ omarchy-live-wallpaper-menu-start/,/\/\/ omarchy-live-wallpaper-menu-end/d' "$MENU_EXT"
  echo "Removed menu override."
fi

# 2. Remove the theme-set hook.
rm -f "$HOME/.config/omarchy/hooks/theme-set.d/10-live-wallpaper.sh"
echo "Removed theme-set hook."

# 3. Remove CLI symlinks.
for name in omarchy-live-wallpaper omarchy-bg-switcher omarchy-bg-set; do
  rm -f "$HOME/.local/bin/$name"
done
echo "Removed CLI symlinks."

# 4. Stop the live wallpaper and clear state.
pkill -x mpvpaper 2>/dev/null || true
rm -rf "$HOME/.local/state/omarchy/live-wallpaper"
echo "Stopped live wallpaper and cleared state."

echo "--- Done ---"
echo "Plugin folder left in place. Remove it with:"
echo "  rm -rf ~/.config/omarchy/plugins/taxin.live-wallpaper"