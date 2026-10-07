import SwiftUI

struct ContentView: View {
    @State private var model = CounterModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("__DISPLAY_NAME__")
                    .font(.largeTitle.bold())
                Text("\(model.count)")
                    .font(.system(size: 72, weight: .semibold, design: .rounded))
                    .contentTransition(.numericText())
                    .accessibilityIdentifier("counterLabel")
                Button("Tap me") {
                    withAnimation { model.increment() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("incrementButton")
            }
            .padding()
            .navigationTitle("__DISPLAY_NAME__")
        }
    }
}

#Preview("iPhone") {
    ContentView()
}
