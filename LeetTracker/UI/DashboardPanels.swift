import SwiftUI

struct StatsHighlightBoard: View {
    let total: String
    let easy: String
    let medium: String
    let hard: String
    let username: String
    let lastUpdated: String

    var body: some View {
        Panel {
            VStack(spacing: 24) {
                HStack(spacing: 10) {
                    Text(username)
                        .font(.title3.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Circle()
                        .fill(AppColor.ink.opacity(0.42))
                        .frame(width: 5, height: 5)
                    
                    Text(lastUpdated)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                VStack(spacing: 4) {
                    Text(total)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        
                    Text("Total Solved")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                HStack(spacing: 0) {
                    difficultyColumn(title: "Easy", count: easy, color: AppColor.easy)
                    
                    Divider().frame(height: 40)
                    
                    difficultyColumn(title: "Medium", count: medium, color: AppColor.medium)
                    
                    Divider().frame(height: 40)
                    
                    difficultyColumn(title: "Hard", count: hard, color: AppColor.hard)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private func difficultyColumn(title: String, count: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(count)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
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
        .background(AppColor.paperWarm.opacity(0.75), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColor.line.opacity(0.3), lineWidth: 1)
        }
    }
}


