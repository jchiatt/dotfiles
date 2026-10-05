import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Reading popup for the daily verse and quote. Owns the data: `today` feeds
// the bar label, `shown` is whatever day the popup is browsing.
//
// Keys: ←/→ (h/l) browse days, t back to today, c copy verse, q copy quote,
// o open the passage on esv.org, Esc close.
Panel {
  id: root
  moduleName: "jc.daily-word"
  ipcTarget: "jc.daily-word"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  readonly property string script: String(Qt.resolvedUrl("daily-word")).replace(/^file:\/\//, "")

  property var today: null
  property var shown: null
  property int offset: 0
  property string todayDate: Qt.formatDate(new Date(), "yyyy-MM-dd")

  readonly property color fg: Color.popups.text
  readonly property color muted: Util.alpha(fg, 0.6)
  readonly property var verse: shown ? shown.verse : null
  readonly property var quote: shown ? shown.quote : null

  function open() {
    offset = 0
    shown = today
    root.controller.show()
    if (!today || today.verse.status !== "ok") refresh()
  }

  function close() {
    setCenterHoverRevealSuppressed(false)
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else {
      root.open()
      Qt.callLater(function() { if (root.opened) setCenterHoverRevealSuppressed(true) })
    }
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
  }

  function refresh() {
    todayDate = Qt.formatDate(new Date(), "yyyy-MM-dd")
    if (!todayProc.running) todayProc.running = true
  }

  function browse(delta) {
    offset = delta === 0 ? 0 : offset + delta
    if (offset === 0) { shown = today; return }
    browseProc.running = false
    browseProc.command = ["python3", root.script, "--json", "--offset", String(offset)]
    browseProc.running = true
  }

  function parse(raw) {
    try { return JSON.parse(String(raw || "").trim()) } catch (e) { return null }
  }

  function copy(text) {
    if (text) Util.execArgv(["wl-copy", text])
  }

  function copyVerse() {
    if (verse && verse.text) copy("“" + verse.text + "” — " + verse.reference + " (ESV)")
  }

  function copyQuote() {
    if (quote) copy("“" + quote.text + "” — " + quote.author + (quote.source ? ", " + quote.source : ""))
  }

  function openOnEsv() {
    if (verse) Util.execArgv(["xdg-open", verse.url])
  }

  function longDate(iso) {
    var p = String(iso || "").split("-")
    if (p.length !== 3) return ""
    return Qt.formatDate(new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2])), "dddd, MMMM d")
  }

  Process {
    id: todayProc
    command: ["python3", root.script, "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var data = root.parse(text)
        if (!data) return
        root.today = data
        if (root.offset === 0) root.shown = data
      }
    }
  }

  Process {
    id: browseProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var data = root.parse(text)
        if (data && data.offset === root.offset) root.shown = data
      }
    }
  }

  Component.onCompleted: refresh()

  // Roll over at midnight, and retry a failed or keyless fetch every 15 min
  // (the key file may have been added since).
  Timer {
    interval: 60 * 1000
    running: true
    repeat: true
    property int ticks: 0
    onTriggered: {
      ticks++
      var stale = Qt.formatDate(new Date(), "yyyy-MM-dd") !== root.todayDate
      var failed = !root.today || root.today.verse.status !== "ok"
      if (stale || (failed && ticks % 15 === 0)) root.refresh()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(520))
    contentHeight: panel.fittedContentHeight(body.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onMoveRequested: function(dx, dy) { if (dx !== 0) root.browse(dx) }
      onTextKey: function(t) {
        if (t === "t") root.browse(0)
        else if (t === "c") root.copyVerse()
        else if (t === "q") root.copyQuote()
        else if (t === "o") root.openOnEsv()
      }

      Flickable {
        id: scroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: body
          width: scroll.width
          spacing: Style.space(12)

          // ---- Date + day navigation
          Item {
            width: parent.width
            height: Math.max(dateLabel.implicitHeight, nav.implicitHeight)

            PanelSectionHeader {
              id: dateLabel
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              foreground: root.fg
              text: (root.offset === 0 ? "TODAY · " : "") + root.longDate(root.shown ? root.shown.date : root.todayDate).toUpperCase()
            }

            Row {
              id: nav
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              PanelActionButton {
                iconText: ""  // nf-fa-chevron_left
                fontSize: Style.font.bodySmall
                foreground: root.fg
                tooltipText: "Previous day"
                onClicked: root.browse(-1)
              }
              PanelActionButton {
                iconText: ""  // nf-fa-home
                fontSize: Style.font.bodySmall
                foreground: root.fg
                enabled: root.offset !== 0
                tooltipText: "Today"
                onClicked: root.browse(0)
              }
              PanelActionButton {
                iconText: ""  // nf-fa-chevron_right
                fontSize: Style.font.bodySmall
                foreground: root.fg
                tooltipText: "Next day"
                onClicked: root.browse(1)
              }
            }
          }

          // ---- Verse
          Column {
            width: parent.width
            spacing: Style.space(6)

            Row {
              spacing: Style.space(8)

              Text {
                id: referenceLabel
                textFormat: Text.PlainText
                text: root.verse ? root.verse.reference : "…"
                color: Color.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
              }
              Text {
                textFormat: Text.PlainText
                height: referenceLabel.height
                verticalAlignment: Text.AlignVCenter
                text: "ESV"
                color: root.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
              }
            }

            Text {
              width: parent.width
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              lineHeight: 1.25
              text: root.verse ? (root.verse.text || root.verse.message) : ""
              color: root.verse && root.verse.text ? root.fg : root.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.heading
            }
          }

          PanelSeparator { foreground: root.fg }

          // ---- Quote
          Column {
            width: parent.width
            spacing: Style.space(6)

            Text {
              width: parent.width
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              lineHeight: 1.25
              text: root.quote ? "“" + root.quote.text + "”" : ""
              color: root.fg
              font.family: Style.font.family
              font.pixelSize: Style.font.subtitle
              font.italic: true
            }

            Text {
              width: parent.width
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              text: root.quote ? "— " + root.quote.author : ""
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
            }

            Text {
              width: parent.width
              visible: text !== ""
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              text: root.quote ? root.quote.source : ""
              color: root.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }
          }

          PanelSeparator { foreground: root.fg }

          // ---- Actions + ESV notice
          Item {
            width: parent.width
            height: Math.max(actions.implicitHeight, notice.implicitHeight)

            Text {
              id: notice
              anchors.left: parent.left
              anchors.right: actions.left
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              text: "Scripture quotations are from the ESV® Bible, © 2001 by Crossway."
              color: root.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Row {
              id: actions
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              PanelActionButton {
                iconText: ""  // nf-fa-copy
                foreground: root.fg
                enabled: root.verse && root.verse.text !== ""
                tooltipText: "Copy verse (c)"
                onClicked: root.copyVerse()
              }
              PanelActionButton {
                iconText: ""  // nf-fa-quote_left
                foreground: root.fg
                tooltipText: "Copy quote (q)"
                onClicked: root.copyQuote()
              }
              PanelActionButton {
                iconText: ""  // nf-fa-external_link
                foreground: root.fg
                tooltipText: "Read in context on esv.org (o)"
                onClicked: root.openOnEsv()
              }
            }
          }
        }
      }
    }
  }
}
