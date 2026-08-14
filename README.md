# taxin.live-wallpaper

mpvpaper live video wallpapers integrated into Omarchy's background switcher
(`Super+Ctrl+Space`), as a proper Omarchy plugin. Install it with one command,
no manual steps.

## Requirements

- [mpvpaper](https://aur.archlinux.org/packages/mpvpaper) (AUR) — the video
  renderer.
- `ffmpeg` — generates the video poster thumbnails shown in the background
  grid.
- `jq` — detects that the video layer is rendering.
- `socat` — talks to mpv's IPC socket so switching live wallpapers swaps
  inside the running instance (no gap, no flicker).

All four are installed automatically when missing (a terminal opens where you
type your sudo password). You can also install them manually:

```bash
yay -S mpvpaper ffmpeg jq socat
```

## Install

```bash
omarchy plugin add https://github.com/taxin-404/live-wallpaper.git --enable
```

That's it. On first load the plugin registers itself automatically:

- installs the system dependencies (mpvpaper, ffmpeg, jq, socat) — a terminal
  opens for your sudo password,
- adds the **Background** row override to the `Super+Ctrl+Space` menu, so the
  picker shows live wallpapers alongside static ones.

Everything lives in user space (`~/.config`, `~/.local`, `~/.cache`) — nothing
under `/usr/share/omarchy/` is touched, so `omarchy update` never resets it.

## Add videos

Drop `.mp4` / `.webm` / `.mkv` / `.mov` / `.avi` files into the shared `live/`
folder. It is theme-independent, so the videos stay in the picker no matter
which theme is active:

```bash
mkdir -p ~/.config/omarchy/backgrounds/live
cp ~/Videos/my-wallpaper.mp4 ~/.config/omarchy/backgrounds/live/
```

## Usage

- Press **Super+Ctrl+Space** to open the background switcher. Videos appear in
  the grid with a frame thumbnail. Pick one to play it, or pick an image to
  restore a static background.
- The active live wallpaper is restored automatically after login.
- Changing the theme never interrupts the live wallpaper: the video runs on
  the `bottom` layer above the theme wallpaper (below the bar and windows), so
  theme changes only swap the static behind it.
- Manual control:

```bash
omarchy-live-wallpaper set  ~/Videos/wall.mp4   # start
omarchy-live-wallpaper stop                     # stop (static shows)
omarchy-live-wallpaper status                   # current live video or "none"
```

The video plays looped, muted, and auto-paused when covered (`no-audio --loop
--hwdec=auto-copy --auto-pause`). Switching is seamless — the theme wallpaper
stays behind the video, so there is never a black frame.

## Uninstall

```bash
omarchy plugin remove taxin.live-wallpaper
```

The menu row auto-hides once the plugin folder is gone. For a spotless wipe
(state, cache, generated config):

```bash
~/.config/omarchy/plugins/taxin.live-wallpaper/bin/omarchy-live-uninstall
```
