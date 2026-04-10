import AppKit

private let cellSize: CGFloat = 100
private let gap: CGFloat = 8
private let padding: CGFloat = 20
private let cols = 4
private let rows = 6

struct KeyDef {
    let label: String
    let keyCode: UInt16
    let col: Int
    let row: Int
    let colSpan: Int
    let rowSpan: Int
    let color: NSColor
    let useEllipse: Bool
}

let allKeys: [KeyDef] = [
    // Row 0: navigation
    KeyDef(label: "Home",  keyCode: 0x73, col: 0, row: 0, colSpan: 1, rowSpan: 1, color: .systemBlue,   useEllipse: false),
    KeyDef(label: "End",   keyCode: 0x77, col: 1, row: 0, colSpan: 1, rowSpan: 1, color: .systemBlue,   useEllipse: false),
    KeyDef(label: "PgUp",  keyCode: 0x74, col: 2, row: 0, colSpan: 1, rowSpan: 1, color: .systemBlue,   useEllipse: false),
    KeyDef(label: "PgDn",  keyCode: 0x79, col: 3, row: 0, colSpan: 1, rowSpan: 1, color: .systemBlue,   useEllipse: false),
    // Row 1: NumLock row
    KeyDef(label: "NmLk",  keyCode: 0x47, col: 0, row: 1, colSpan: 1, rowSpan: 1, color: .systemPurple, useEllipse: false),
    KeyDef(label: "/",     keyCode: 0x4B, col: 1, row: 1, colSpan: 1, rowSpan: 1, color: .systemOrange, useEllipse: false),
    KeyDef(label: "*",     keyCode: 0x43, col: 2, row: 1, colSpan: 1, rowSpan: 1, color: .systemOrange, useEllipse: false),
    KeyDef(label: "-",     keyCode: 0x4E, col: 3, row: 1, colSpan: 1, rowSpan: 1, color: .systemOrange, useEllipse: false),
    // Row 2: 7 8 9 | + (top, spans rows 2–3)
    KeyDef(label: "7",     keyCode: 0x59, col: 0, row: 2, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "8",     keyCode: 0x5B, col: 1, row: 2, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "9",     keyCode: 0x5C, col: 2, row: 2, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "+",     keyCode: 0x45, col: 3, row: 2, colSpan: 1, rowSpan: 2, color: .systemRed,    useEllipse: false),
    // Row 3: 4 5 6 (+ continues)
    KeyDef(label: "4",     keyCode: 0x56, col: 0, row: 3, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "5",     keyCode: 0x57, col: 1, row: 3, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "6",     keyCode: 0x58, col: 2, row: 3, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    // Row 4: 1 2 3 | NEnter (top, spans rows 4–5)
    KeyDef(label: "1",     keyCode: 0x53, col: 0, row: 4, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "2",     keyCode: 0x54, col: 1, row: 4, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "3",     keyCode: 0x55, col: 2, row: 4, colSpan: 1, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: "Enter", keyCode: 0x4C, col: 3, row: 4, colSpan: 1, rowSpan: 2, color: .systemYellow, useEllipse: false),
    // Row 5: 0 (wide) | . | (NEnter continues)
    KeyDef(label: "0",     keyCode: 0x52, col: 0, row: 5, colSpan: 2, rowSpan: 1, color: .systemGreen,  useEllipse: true),
    KeyDef(label: ".",     keyCode: 0x41, col: 2, row: 5, colSpan: 1, rowSpan: 1, color: .systemTeal,   useEllipse: true),
]

@MainActor
class NumpadView: NSView {
    private var pressedKeys = Set<UInt16>()
    private var localMonitor: Any?

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            MainActor.assumeIsolated { self?.handle(event) }
            return event
        }
    }

    private func handle(_ event: NSEvent) {
        let kc = event.keyCode
        guard allKeys.contains(where: { $0.keyCode == kc }) else { return }
        if event.type == .keyDown {
            pressedKeys.insert(kc)
        } else {
            pressedKeys.remove(kc)
        }
        needsDisplay = true
    }

    deinit {
        if let m = localMonitor { NSEvent.removeMonitor(m) }
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.windowBackgroundColor.setFill()
        bounds.fill()

        for key in allKeys {
            let rect = rectFor(key)
            let pressed = pressedKeys.contains(key.keyCode)

            let path: NSBezierPath = key.useEllipse
                ? NSBezierPath(ovalIn: rect)
                : NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10)

            if pressed {
                key.color.withAlphaComponent(0.85).setFill()
                path.fill()
            }

            (pressed ? key.color : NSColor.separatorColor).setStroke()
            path.lineWidth = pressed ? 2 : 1
            path.stroke()

            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14, weight: pressed ? .bold : .regular),
                .foregroundColor: pressed ? NSColor.white : NSColor.tertiaryLabelColor,
            ]
            let labelSize = (key.label as NSString).size(withAttributes: attrs)
            let labelOrigin = CGPoint(
                x: rect.midX - labelSize.width / 2,
                y: rect.midY - labelSize.height / 2
            )
            (key.label as NSString).draw(at: labelOrigin, withAttributes: attrs)
        }
    }

    private func rectFor(_ key: KeyDef) -> NSRect {
        let x = padding + CGFloat(key.col) * (cellSize + gap)
        let y = padding + CGFloat(key.row) * (cellSize + gap)
        let w = CGFloat(key.colSpan) * cellSize + CGFloat(key.colSpan - 1) * gap
        let h = CGFloat(key.rowSpan) * cellSize + CGFloat(key.rowSpan - 1) * gap
        return NSRect(x: x, y: y, width: w, height: h)
    }

    override var intrinsicContentSize: NSSize {
        let w = CGFloat(cols) * cellSize + CGFloat(cols - 1) * gap + 2 * padding
        let h = CGFloat(rows) * cellSize + CGFloat(rows - 1) * gap + 2 * padding
        return NSSize(width: w, height: h)
    }
}
