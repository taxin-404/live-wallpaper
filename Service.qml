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

  function runScript(command) {
    if (installProc.running) return
    installProc.command = ["bash", "-lc", command]
    installProc.running = true
  }

  function runLiveWallpaper(command) {
    if (!root.pluginDir) return
    runScript("\"" + root.pluginDir + "/bin/omarchy-live-wallpaper\" " + command)
  }

  // First load: self-install the menu override + theme hook, then restore the
  // active live wallpaper once the shell has settled.
  Timer {
    interval: 1200
    repeat: false
    running: true
    onTriggered: root.runScript("\"" + root.pluginDir + "/bin/omarchy-live-install\"")
  }

  Timer {
    interval: 2000
    repeat: false
    running: true
    onTriggered: root.runLiveWallpaper("restore")
  }

  Process {
    id: installProc
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