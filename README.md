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
  picker shows live wallpapers alongside static ones,
- installs user-space shims so the wallpaper **double-click** also opens the
  live-capable picker (see below).

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
- **Double-clicking the desktop** opens the same live-capable picker. The shell
  background plugin calls the stock `omarchy-theme-bg-switcher` /
  `omarchy-theme-bg-set` by bare name, so the plugin shadows those two commands
  with wrappers in `~/.local/bin/omarchy-live-shims/` and prepends that
  directory to the session `PATH` via `~/.config/uwsm/env.d/99-live-wallpaper`.
  The new `PATH` only takes effect on your next login. Everything is removed on
  uninstall.
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

The video plays looped, muted, and auto-paused when covered or when any window
is fullscreen (`no-audio --loop --hwdec=auto-copy --framedrop=vo
--video-sync=display --auto-pause --auto-mode FULL`). `framedrop=vo` lets mpv
drop frames instead of stalling the compositor on slow CPUs; `video-sync=display`
presents each frame at its native rate and trims the render loop's CPU.
Switching is seamless — the theme wallpaper stays behind the video, so there is
never a black frame.

### Tuning (resource use)

The renderer's CPU cost is mostly its per-frame render loop (largely independent
of video resolution), so the levers below matter more than file size on their
own:

- `OMARCHY_LIVE_AUTO_MODE` — pauses the video when a window covers the desktop,
  freeing the GPU/decoder. `FULL` (default) pauses under any fullscreen window,
  `MAX` also pauses when a window is maximized, `none` never pauses.
- `OMARCHY_LIVE_HWDEC` — mpv hardware decoding mode, default `auto-copy`
  (GPU decode, best compatibility). Set `none` if your GPU driver has no
  working VAAPI, or force a specific mode (e.g. `vaapi`, `nvdec`) if needed.

Set them before the shell starts (e.g. in `~/.config/uwsm/env.d/`) so mpvpaper
inherits them.

For weak hardware, re-encode heavy videos: a smaller/lower-fps file shrinks the
GPU, decode, and disk/IO cost (and matters more on compositors that scale render
work with resolution). Non-destructive — it writes a leaner copy beside the
original:

```bash
~/.config/omarchy/plugins/taxin.live-wallpaper/bin/omarchy-live-optimize ~/Videos/my.mp4
# options: --fps 24 (default) --crf 28 (default) --scale 1280
# result: ~/Videos/my.live.mp4  →  mv my.live.mp4 my.mp4
```

The plugin also skips re-checking its dependencies for a few minutes after a
successful check (a boot-stamped cache marker), so opening the picker or
switching wallpapers spawns no extra process on a healthy system.

## Uninstall

```bash
omarchy plugin remove taxin.live-wallpaper
```

The menu row auto-hides once the plugin folder is gone. For a spotless wipe
(state, cache, generated config):

```bash
~/.config/omarchy/plugins/taxin.live-wallpaper/bin/omarchy-live-uninstall
```
