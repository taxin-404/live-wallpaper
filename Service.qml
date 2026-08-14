import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root

  // Injected by omarchy-shell (the service loader).
  property var shell: null

  function runLiveWallpaper(command) {
    if (liveWallpaperProc.running) return
    liveWallpaperProc.command = ["bash", "-lc", "omarchy-live-wallpaper " + command]
    liveWallpaperProc.running = true
  }

  Process {
    id: liveWallpaperProc
  }

  // Restore the active live wallpaper once the shell has settled after login.
  // The static background layer loads first, so a short delay is required.
  Timer {
    interval: 1500
    repeat: false
    running: true
    onTriggered: root.runLiveWallpaper("restore")
  }

  IpcHandler {
    target: "live-wallpaper"

    function set(path: string): void {
      root.runLiveWallpaper("set \"" + path + "\"")
    }
    function stop(): void {
      root.runLiveWallpaper("stop")
    }
    function restore(): void {
      root.runLiveWallpaper("restore")
    }
  }
}