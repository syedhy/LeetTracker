import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        Text("LeetTracker")
            .frame(minWidth: 360, minHeight: 240)
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
            }
    }
}

#Preview {
    ContentView()
}
