import SwiftUI
import AppKit

struct NumpadRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> NumpadView {
        NumpadView(frame: .zero)
    }
    func updateNSView(_ nsView: NumpadView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        NumpadRepresentable()
            .frame(
                width: CGFloat(4) * 100 + CGFloat(3) * 8 + 40,
                height: CGFloat(6) * 100 + CGFloat(5) * 8 + 40
            )
    }
}
