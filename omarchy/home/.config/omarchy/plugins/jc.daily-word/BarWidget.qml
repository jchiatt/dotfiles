import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Bar label for the daily verse (cross + reference), and host for the reading
// popup. Hovering shows the verse text in a wrapped card; left click opens the
// popup with the verse and quote; middle click refetches.
BarWidget {
  id: root
  moduleName: "jc.daily-word"

  readonly property var panel: panelLoader.item
  readonly property var today: panel ? panel.today : null
  readonly property var verse: today ? today.verse : null

  readonly property string reference: verse ? verse.reference : ""
  readonly property string hoverText: verse ? (verse.text || verse.message) : ""

  // The bar's shared tooltip is one unwrapped line, so the hover card is our
  // own: as wide as the widget, but never narrower than hoverMinWidth.
  readonly property real hoverWidth: Math.max(button.width, Style.space(Number(setting("hoverMinWidth", 280)) || 280))

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

  visible: !vertical && reference !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

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
    text: "󰥓  " + root.reference  // nf-md-cross
    horizontalMargin: 8.75

    onPressed: function(b) {
      hoverDelay.stop()
      hoverCard.shown = false
      if (b === Qt.MiddleButton) root.refresh()
      else if (b === Qt.LeftButton) root.togglePanel()
    }
  }

  HoverHandler {
    id: hover
    onHoveredChanged: {
      if (hovered && !root.opened && root.hoverText !== "") hoverDelay.restart()
      else { hoverDelay.stop(); hoverCard.shown = false }
    }
  }

  Timer {
    id: hoverDelay
    interval: 400
    onTriggered: hoverCard.shown = hover.hovered && !root.opened
  }

  PopupWindow {
    id: hoverCard

    property bool shown: false

    visible: shown && !root.opened && root.hoverText !== ""
    color: "transparent"
    implicitWidth: Math.ceil(root.hoverWidth)
    implicitHeight: Math.ceil(bubble.implicitHeight)

    anchor {
      id: hoverAnchor
      window: button.QsWindow.window
      adjustment: PopupAdjustment.Slide
      edges: Edges.Top | Edges.Left
      gravity: Edges.Bottom | Edges.Right
      rect.width: 1
      rect.height: 1

      onAnchoring: {
        var window = button.QsWindow.window
        if (!window) return
        var bottom = root.bar && root.bar.position === "bottom"
        var localX = button.width / 2 - hoverCard.implicitWidth / 2
        var localY = bottom ? -hoverCard.implicitHeight - 6 : button.height + 6
        var point = window.contentItem.mapFromItem(button, localX, localY)
        hoverAnchor.rect.x = Math.round(Math.max(6, Math.min(point.x, window.width - hoverCard.implicitWidth - 6)))
        hoverAnchor.rect.y = Math.round(point.y)
      }
    }

    BorderSurface {
      id: bubble
      width: parent.width
      implicitHeight: hoverLabel.implicitHeight + 14
      color: Color.tooltip.background
      borderSpec: Border.surfaceSpec("tooltip", "border", Color.tooltip.border, 1)
      radius: Style.cornerRadius

      Text {
        id: hoverLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        lineHeight: 1.2
        text: root.hoverText
        color: Color.tooltip.text
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
      }
    }
  }
}
