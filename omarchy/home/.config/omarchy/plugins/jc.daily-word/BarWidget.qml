import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Bar label for the daily verse + quote, and host for the reading popup.
// Left click opens the popup, right click cycles what the bar shows
// (rotate → verse → quote), middle click refetches.
BarWidget {
  id: root
  moduleName: "jc.daily-word"

  readonly property var panel: panelLoader.item
  readonly property var today: panel ? panel.today : null

  // "verse" | "quote" | "rotate"; right click overrides shell.json until restart.
  property string displayOverride: ""
  readonly property string display: displayOverride !== "" ? displayOverride : String(setting("display", "rotate"))
  readonly property int maxChars: Math.max(16, Number(setting("maxChars", 60)) || 60)
  property bool showingQuote: display === "quote"

  readonly property string verseLine: {
    if (!today) return ""
    var v = today.verse
    return v.text ? v.reference + " — " + v.text : v.reference
  }
  readonly property string quoteLine: today ? today.quote.text + " — " + today.quote.author : ""
  readonly property string fullLine: showingQuote ? quoteLine : verseLine
  readonly property string icon: showingQuote ? "" : "󰥓"  // nf-fa-quote_left, nf-md-cross

  function clip(text) {
    return text.length > maxChars ? text.slice(0, maxChars - 1).replace(/[\s,;:—-]+$/, "") + "…" : text
  }

  function cycleDisplay() {
    displayOverride = display === "rotate" ? "verse" : (display === "verse" ? "quote" : "rotate")
    showingQuote = displayOverride === "quote"
  }

  function refresh() { if (panel) panel.refresh() }

  // ---- Popup shape contract (Bar.findPanelWidget needs open/close/opened).
  readonly property bool opened: panel ? panel.opened === true : false
  readonly property bool popoutSwitchClosing: panel ? panel.popoutSwitchClosing === true : false
  function open() { if (panel) panel.open() }
  function close() { if (panel) panel.close() }
  function togglePanel() { if (panel) panel.toggle() }
  function closeForPopoutSwitch() { if (panel) panel.closeForPopoutSwitch() }

  readonly property real openPanelIndicatorWidth: button.labelWidth

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  visible: !vertical && fullLine !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()
  onDisplayChanged: if (display !== "rotate") showingQuote = display === "quote"

  Timer {
    interval: Math.max(5, Number(root.setting("rotateSeconds", 60)) || 60) * 1000
    running: root.display === "rotate" && !root.opened
    repeat: true
    onTriggered: fade.restart()
  }

  SequentialAnimation {
    id: fade
    NumberAnimation { target: button; property: "opacity"; to: 0; duration: 180; easing.type: Easing.InCubic }
    ScriptAction { script: root.showingQuote = !root.showingQuote }
    NumberAnimation { target: button; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  IpcHandler {
    target: "jc.daily-word"

    function refresh(): void { root.broadcast("refresh") }
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.togglePanel() }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon + "  " + root.clip(root.fullLine)
    tooltipText: root.opened ? "" : root.fullLine
    horizontalMargin: 8.75

    onPressed: function(b) {
      if (b === Qt.RightButton) root.cycleDisplay()
      else if (b === Qt.MiddleButton) root.refresh()
      else root.togglePanel()
    }
  }
}
