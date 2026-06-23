import WidgetKit
import SwiftUI

@main
struct LeetTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        LeetTrackerWidget()
        LeetTrackerStreakWidget()
    }
}
