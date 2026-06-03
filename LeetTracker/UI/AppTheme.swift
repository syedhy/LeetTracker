import SwiftUI

enum AppColor {
    static let ink = Color(red: 0.08, green: 0.08, blue: 0.075)
    static let paper = Color(red: 0.998, green: 0.998, blue: 0.994)
    static let paperWarm = Color(red: 0.988, green: 0.988, blue: 0.982)
    static let graphite = Color(red: 0.42, green: 0.42, blue: 0.39)
    static let line = Color(red: 0.12, green: 0.12, blue: 0.11)
    static let brand = ink
    static let easy = Color(red: 0.18, green: 0.73, blue: 0.38)
    static let medium = Color(red: 0.95, green: 0.58, blue: 0.08)
    static let hard = Color(red: 0.92, green: 0.25, blue: 0.42)
}

struct AppSurfaceBackground: View {
    var body: some View {
        ZStack {
            AppColor.paper

            PaperGridBackdrop()
                .stroke(AppColor.line.opacity(0.02), lineWidth: 1)
                .padding(18)
        }
        .ignoresSafeArea()
    }
}

struct PaperGridBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 48

        var x = rect.minX
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }

        var y = rect.minY
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += step
        }

        return path
    }
}

struct SectionEntranceModifier: ViewModifier {
    let trigger: String
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.12), value: isVisible)
            .onAppear {
                isVisible = true
            }
            .onChange(of: trigger) { _, _ in
                isVisible = false

                DispatchQueue.main.async {
                    isVisible = true
                }
            }
    }
}

extension View {
    func sectionEntrance(trigger: String) -> some View {
        modifier(SectionEntranceModifier(trigger: trigger))
    }
}

struct AppIconMark: View {
    var body: some View {
        VStack(spacing: 5) {
            CodeMarkShape()
                .fill(AppColor.ink)
                .frame(width: 34, height: 26)

            HStack(spacing: 4) {
                Circle()
                    .fill(AppColor.easy)
                Circle()
                    .fill(AppColor.medium)
                Circle()
                    .fill(AppColor.hard)
            }
            .frame(width: 24, height: 5)
        }
        .padding(9)
        .background(AppColor.paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColor.line.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: AppColor.ink.opacity(0.08), radius: 10, y: 6)
    }
}

struct CodeMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lineWidth = rect.height * 0.22
        let leftX = rect.minX + rect.width * 0.28
        let rightX = rect.minX + rect.width * 0.72
        let midY = rect.midY
        let chevronHeight = rect.height * 0.32
        let chevronWidth = rect.width * 0.18

        var left = Path()
        left.move(to: CGPoint(x: leftX, y: midY - chevronHeight))
        left.addLine(to: CGPoint(x: leftX - chevronWidth, y: midY))
        left.addLine(to: CGPoint(x: leftX, y: midY + chevronHeight))
        path.addPath(left.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)))

        var slash = Path()
        slash.move(to: CGPoint(x: rect.midX + rect.width * 0.07, y: rect.minY + rect.height * 0.12))
        slash.addLine(to: CGPoint(x: rect.midX - rect.width * 0.07, y: rect.maxY - rect.height * 0.12))
        path.addPath(slash.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)))

        var right = Path()
        right.move(to: CGPoint(x: rightX, y: midY - chevronHeight))
        right.addLine(to: CGPoint(x: rightX + chevronWidth, y: midY))
        right.addLine(to: CGPoint(x: rightX, y: midY + chevronHeight))
        path.addPath(right.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)))

        return path
    }
}
