import SwiftUI
import WidgetKit

struct WidgetContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(.background, for: .widget)
    }
}

struct WidgetStatRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack(spacing: LTWidgetSpacing.medium) {
            Text(title)
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.secondary)

            Spacer(minLength: LTWidgetSpacing.medium)

            Text("\(value)")
                .font(LTWidgetTypography.label.weight(.semibold))
                .foregroundStyle(LTWidgetColor.primary)
                .frame(minWidth: LTWidgetSizing.minimumReadableWidth, alignment: .trailing)
        }
    }
}

struct WidgetEmptyStateView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
            Text("LeetTracker")
                .font(LTWidgetTypography.title)

            Spacer()

            Text(message)
                .font(LTWidgetTypography.emptyState)
                .foregroundStyle(LTWidgetColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WidgetErrorStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.small) {
            Text(title)
                .font(LTWidgetTypography.title)

            Spacer()

            Text(message)
                .font(LTWidgetTypography.label)
                .foregroundStyle(LTWidgetColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WidgetLoadingStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LTWidgetSpacing.medium) {
            Text("LeetTracker")
                .font(LTWidgetTypography.title)

            Spacer()

            Text("Updating stats...")
                .font(LTWidgetTypography.emptyState)
                .foregroundStyle(LTWidgetColor.secondary)
        }
    }
}
