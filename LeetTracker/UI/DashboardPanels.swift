import SwiftUI

struct TotalSolvedCard: View {
    let total: String
    let username: String
    let lastUpdated: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.headline)
                        .foregroundStyle(AppColor.paper.opacity(0.76))
                        .lineLimit(1)

                    Text(lastUpdated)
                        .font(.caption)
                        .foregroundStyle(AppColor.paper.opacity(0.52))
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.paper)
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(total)
                    .font(.system(size: 58, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.paper)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("solved")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColor.paper.opacity(0.62))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppColor.ink,
                    Color(red: 0.02, green: 0.02, blue: 0.018)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.line, lineWidth: 1.2)
        }
    }
}

struct DifficultyCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 10, height: 10)

            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.64), lineWidth: 1.2)
        }
    }
}

struct StatusPanel: View {
    let message: String
    let isLoading: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 2)
            } else {
                Image(systemName: "info.circle.fill")
                    .font(.body)
                    .foregroundStyle(AppColor.ink)
                    .padding(.top, 2)
            }

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(AppColor.paperWarm.opacity(0.75), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.line.opacity(0.3), lineWidth: 1)
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)

            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.paperWarm.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.48), lineWidth: 1)
        }
    }
}
