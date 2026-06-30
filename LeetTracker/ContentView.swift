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
        .preferredColorScheme(.light)
        .fontDesign(.rounded)
        .fontWeight(.black)
        .background(AppSurfaceBackground())
        #else
        NavigationSplitView {
            ZStack {
                AppSurfaceBackground()
                
                VStack(spacing: 8) {
                    ForEach([AppSection.dashboard, .practice, .widgets]) { section in
                        sidebarButton(for: section)
                    }
                    
                    Spacer()
                    
                    sidebarButton(for: .settings)
                }
                .padding(14)
            }
            .navigationTitle("LeetTracker")
        } detail: {
            ZStack {
                AppSurfaceBackground()
                
                VStack(alignment: .leading, spacing: 26) {
                    selectedContent
                        .sectionEntrance(trigger: "\(selectedSection.rawValue)-\(selectedPracticeMode.rawValue)")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .onAppear {
            viewModel.loadSavedState()
        }
        .preferredColorScheme(.light)
        .fontDesign(.rounded)
        .fontWeight(.black)
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

    @ViewBuilder
    private func sidebarButton(for section: AppSection) -> some View {
        Button(action: { selectedSection = section }) {
            HStack(spacing: 12) {
                Image(systemName: section.systemImage)
                    .font(.title3.weight(.bold))
                    .frame(width: 24)
                Text(section.rawValue)
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .foregroundStyle(selectedSection == section ? AppColor.paper : AppColor.ink)
            .background(
                selectedSection == section ? AppColor.ink : Color.clear,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
