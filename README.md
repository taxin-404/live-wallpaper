# taxin.live-wallpaper

mpvpaper live video wallpapers integrated into Omarchy's background switcher
(`Super+Ctrl+Space`), as a proper Omarchy plugin. Install it with one command,
no manual steps.

## Requirements

- [mpvpaper](https://aur.archlinux.org/packages/mpvpaper) (AUR) — install it
  first:

```bash
yay -S mpvpaper
```

## Install

```bash
# via SSH
omarchy plugin add git@github.com:taxin-404/live-wallpaper.git --enable

# or via HTTPS
omarchy plugin add https://github.com/taxin-404/live-wallpaper.git --enable
```

That's it. On first load the plugin registers itself automatically:

- adds the **Background** row override to the `Super+Ctrl+Space` menu so the
  picker shows live wallpapers alongside static ones,
- installs a theme-set hook that restores the active wallpaper after theme
  changes.

Everything lives in user space (`~/.config`, `~/.local`, `~/.cache`) — nothing
under `/usr/share/omarchy/` is touched, so `omarchy update` never resets it.

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

The video plays looped, muted, and auto-paused when covered (`no-audio --loop
--hwdec=auto-copy --auto-pause`). Switching is seamless — the video layer is
confirmed rendering before the static background is cleared, so there is never
a black frame.

## Uninstall

```bash
omarchy plugin remove taxin.live-wallpaper
```

The menu row auto-hides and the theme hook removes itself once the plugin
folder is gone. For a spotless wipe (state, cache, generated config):

```bash
~/.config/omarchy/plugins/taxin.live-wallpaper/bin/omarchy-live-uninstall
```
