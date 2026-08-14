# taxin.live-wallpaper

mpvpaper live video wallpapers integrated into Omarchy's background switcher.

## Install

```bash
~/.config/omarchy/plugins/taxin.live-wallpaper/install.sh
```

This installs `mpvpaper` (AUR) if missing, symlinks the CLI tools into
`~/.local/bin`, installs a `theme-set` hook, and overrides the `style.background`
menu row so the background switcher shows live wallpapers alongside static ones.

## Add videos

Drop `.mp4` / `.webm` / `.mkv` / `.mov` / `.avi` files into the theme-based
`live/` folder:

```bash
mkdir -p ~/.config/omarchy/backgrounds/ethereal/live
cp ~/Videos/my-wallpaper.mp4 ~/.config/omarchy/backgrounds/ethereal/live/
```

## Usage

- Press **Super+Ctrl+Space** to open the background switcher. Videos appear in
  the grid with a frame thumbnail. Pick one to play it, or pick an image to
  restore a static background.
- The active live wallpaper is restored automatically after login and after
  theme changes.
- Manual control:

```bash
omarchy-live-wallpaper set  ~/Videos/wall.mp4   # start
omarchy-live-wallpaper stop                     # stop (restores static)
omarchy-live-wallpaper status                   # current live video or "none"
```

The video plays looped and muted via `mpvpaper` (`no-audio --loop
--hwdec=auto-copy --auto-pause`). The shell's static background layer is set to
a transparent image while a video is active so it can't cover the playback.

Switching is seamless: the video is started and its layer is confirmed
rendering *before* the static background is cleared, so there is never a black
frame. Switching between two videos briefly restores the static wallpaper
first. `--auto-pause` lets mpvpaper pause the video whenever it is covered by a
fullscreen or maximized window to save GPU/CPU.

## Uninstall

```bash
~/.config/omarchy/plugins/taxin.live-wallpaper/uninstall.sh
rm -rf ~/.config/omarchy/plugins/taxin.live-wallpaper
```

## Notes

- Only user-space paths are used (`~/.config`, `~/.local`, `~/.cache`); nothing
  under `/usr/share/omarchy/` is modified, so `omarchy update` never resets it.
- Desktop double-click still opens the stock static-only switcher.