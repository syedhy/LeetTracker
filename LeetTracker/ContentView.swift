import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case practice = "Practice"
    case widgets = "Widgets"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            return "rectangle.3.group"
        case .practice:
            return "calendar.badge.checkmark"
        case .widgets:
            return "square.grid.2x2"
        case .settings:
            return "gearshape"
        }
    }
}

enum PracticeMode: String, CaseIterable, Identifiable {
    case plan = "Plan"
    case analytics = "Analytics"
    case goals = "Goals"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .plan:
            return "calendar.badge.checkmark"
        case .analytics:
            return "chart.xyaxis.line"
        case .goals:
            return "target"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = LeetTrackerViewModel()
    @State private var selectedSection = AppSection.dashboard
    @State private var selectedPracticeMode = PracticeMode.plan

    var body: some View {
        #if os(iOS)
        TabView(selection: $selectedSection) {
            DashboardView(viewModel: viewModel)
                .tabItem { Label(AppSection.dashboard.rawValue, systemImage: AppSection.dashboard.systemImage) }
                .tag(AppSection.dashboard)
            
            PracticeView(viewModel: viewModel, selectedPracticeMode: $selectedPracticeMode)
                .tabItem { Label(AppSection.practice.rawValue, systemImage: AppSection.practice.systemImage) }
                .tag(AppSection.practice)
                
            WidgetsPageView(viewModel: viewModel)
                .tabItem { Label(AppSection.widgets.rawValue, systemImage: AppSection.widgets.systemImage) }
                .tag(AppSection.widgets)
                
            SettingsPageView(viewModel: viewModel)
                .tabItem { Label(AppSection.settings.rawValue, systemImage: AppSection.settings.systemImage) }
                .tag(AppSection.settings)
        }
        .onAppear {
            viewModel.loadSavedState()
        }
        #else
        NavigationSplitView {
            List(AppSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    Label(section.rawValue, systemImage: section.systemImage)
                }
            }
            .navigationTitle("LeetTracker")
            .listStyle(.sidebar)
        } detail: {
            VStack(alignment: .leading, spacing: 26) {
                selectedContent
                    .sectionEntrance(trigger: "\(selectedSection.rawValue)-\(selectedPracticeMode.rawValue)")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onAppear {
            viewModel.loadSavedState()
        }
        #endif
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .dashboard:
            DashboardView(viewModel: viewModel)
        case .practice:
            PracticeView(viewModel: viewModel, selectedPracticeMode: $selectedPracticeMode)
        case .widgets:
            WidgetsPageView(viewModel: viewModel)
        case .settings:
            SettingsPageView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
