#!/usr/bin/env bash
# taxin.live-wallpaper — installer.
#
#   - Installs mpvpaper (AUR) if missing
#   - Symlinks bin/ tools onto PATH (~/.local/bin)
#   - Installs the theme-set hook (restore after theme changes)
#   - Adds the style.background override to the Omarchy menu extensions so the
#     Super+Ctrl+Space background switcher also shows live wallpapers
#
# Everything lives in user space (~/.config, ~/.local, ~/.cache); nothing under
# /usr/share/omarchy/ is touched, so nothing is lost on `omarchy update`.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "--- taxin.live-wallpaper :: installer ---"

# 1. Dependency: mpvpaper
echo "[1/4] Checking mpvpaper..."
if ! command -v mpvpaper >/dev/null 2>&1; then
  if command -v yay >/dev/null 2>&1; then
    echo "mpvpaper missing. Installing via yay..."
    yay -S --needed mpvpaper
  elif command -v paru >/dev/null 2>&1; then
    echo "mpvpaper missing. Installing via paru..."
    paru -S --needed mpvpaper
  else
    echo "mpvpaper missing and no AUR helper found. Install it manually: yay -S mpvpaper" >&2
    exit 1
  fi
fi
echo "  mpvpaper OK."

# 2. Symlink CLI tools onto PATH
echo "[2/4] Linking CLI tools into ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
for tool in "$PLUGIN_DIR"/bin/*; do
  [[ -f $tool ]] || continue
  name=$(basename "$tool")
  chmod +x "$tool"
  ln -sfn "$tool" "$HOME/.local/bin/$name"
  echo "  linked $name"
done

# 3. Install the theme-set hook
echo "[3/4] Installing theme-set hook..."
if command -v omarchy >/dev/null 2>&1; then
  omarchy hook install theme-set "$PLUGIN_DIR/hooks/10-live-wallpaper.sh"
else
  mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"
  cp "$PLUGIN_DIR/hooks/10-live-wallpaper.sh" "$HOME/.config/omarchy/hooks/theme-set.d/10-live-wallpaper.sh"
  chmod 755 "$HOME/.config/omarchy/hooks/theme-set.d/10-live-wallpaper.sh"
fi

# 4. Menu extension override (marked block, so uninstall can remove it cleanly)
echo "[4/4] Updating menu extension (style.background)..."
MENU_EXT="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
if [[ ! -f $MENU_EXT ]]; then
  mkdir -p "$HOME/.config/omarchy/extensions"
  printf '{\n}\n' > "$MENU_EXT"
fi

# Remove any previous live-wallpaper block and any bare style.background override.
sed -i '/\/\/ omarchy-live-wallpaper-menu-start/,/\/\/ omarchy-live-wallpaper-menu-end/d' "$MENU_EXT"
sed -i '/"style\.background":/d' "$MENU_EXT"

MENU_BLOCK='  // omarchy-live-wallpaper-menu-start
  "style.background": {"icon":"","label":"Background","aliases":["background","wallpaper"],"action":"background=$(omarchy-bg-switcher); [[ -n $background ]] && omarchy-bg-set \"$background\""}
  // omarchy-live-wallpaper-menu-end'

python3 - "$MENU_EXT" "$MENU_BLOCK" <<'PY'
import sys

path, block = sys.argv[1], sys.argv[2]
with open(path) as f:
    content = f.read()

stripped = content.rstrip()
idx = stripped.rfind('}')
if idx == -1:
    sys.exit(f"no closing brace in {path}")

before = stripped[:idx].rstrip()
after = stripped[idx:].lstrip('\n')
new = before + "\n" + block + "\n" + after
with open(path, "w") as f:
    f.write(new)
print("  style.background override added.")
PY

echo "--- Done ---"
echo "Drop videos in:"
echo "  ~/.config/omarchy/backgrounds/<theme>/live/"
echo "then pick them from the background switcher (Super+Ctrl+Space)."