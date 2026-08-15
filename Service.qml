import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root

  // Injected by omarchy-shell (the service loader).
  property var shell: null
  property var manifest: null

  // Absolute folder this plugin lives in (from the injected manifest).
  readonly property string pluginDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir) : ""

  // The installer and the live wallpaper run in separate Process objects so
  // a long-running dependency install can never drop a restore or set — they
  // only block on each other's lock files, never on each other's lifecycle.
  function runInstaller() {
    if (installProc.running) return
    installProc.command = ["bash", "-lc", "\"" + root.pluginDir + "/bin/omarchy-live-install\""]
    installProc.running = true
  }

  // Run omarchy-live-wallpaper with argv (no shell string), so a video or
  // poster path with quotes or shell metacharacters can neither break nor
  // inject into the command line.
  function runLiveWallpaper(args) {
    if (!root.pluginDir) return
    if (liveProc.running) return
    liveProc.command = ["bash", "-lc",
      "\"" + root.pluginDir + "/bin/omarchy-live-wallpaper\" \"$@\"",
      "omarchy-live-wallpaper"].concat(args)
    liveProc.running = true
  }

  // First load: self-install the menu override + shims, then restore the
  // active live wallpaper once the shell has settled. Each runs in its own
  // Process, so neither waits on the other.
  Timer {
    interval: 1200
    repeat: false
    running: true
    onTriggered: root.runInstaller()
  }

  Timer {
    interval: 2000
    repeat: false
    running: true
    onTriggered: root.runLiveWallpaper(["restore"])
  }

  Process {
    id: installProc
  }

  Process {
    id: liveProc
  }

  IpcHandler {
    target: "live-wallpaper"

    function set(path: string): void {
      root.runLiveWallpaper(["set", path])
    }
    function stop(): void {
      root.runLiveWallpaper(["stop"])
    }
    function restore(): void {
      root.runLiveWallpaper(["restore"])
    }
  }
}