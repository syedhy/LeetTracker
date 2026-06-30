import SwiftUI

struct WidgetsPageView: View {
    @ObservedObject var viewModel: LeetTrackerViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                pageHeader(
                    title: "Widgets",
                    subtitle: "Desktop cards for progress and streaks.",
                    systemImage: "square.grid.2x2"
                )

                #if os(iOS)
                VStack(spacing: 20) {
                    WidgetStudioHeroPanel(
                        solvedText: viewModel.totalSolvedText,
                        username: viewModel.displayUsername,
                        refreshText: viewModel.refreshCadenceText
                    )

                    WidgetSetupPanel(
                        refreshText: viewModel.refreshCadenceText,
                        dataText: "Auto refresh when macOS allows it"
                    )
                }
                #else
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        WidgetStudioHeroPanel(
                            solvedText: viewModel.totalSolvedText,
                            username: viewModel.displayUsername,
                            refreshText: viewModel.refreshCadenceText
                        )
                        .frame(maxWidth: .infinity)

                        WidgetSetupPanel(
                            refreshText: viewModel.refreshCadenceText,
                            dataText: "Auto refresh when macOS allows it"
                        )
                        .frame(minWidth: 300, idealWidth: 340, maxWidth: 380)
                    }
                    VStack(spacing: 20) {
                        WidgetStudioHeroPanel(
                            solvedText: viewModel.totalSolvedText,
                            username: viewModel.displayUsername,
                            refreshText: viewModel.refreshCadenceText
                        )

                        WidgetSetupPanel(
                            refreshText: viewModel.refreshCadenceText,
                            dataText: "Auto refresh when macOS allows it"
                        )
                    }
                }
                #endif

                WidgetCatalogPanel()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func pageHeader(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.ink)
                .frame(width: 44, height: 44)
                .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.ink, lineWidth: 1.5)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}
