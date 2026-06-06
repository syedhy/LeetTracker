import SwiftUI

enum AppColor {
    static let ink = Color(red: 0.08, green: 0.08, blue: 0.075)
    static let paper = Color(red: 0.999, green: 0.999, blue: 0.996)
    static let paperWarm = Color(red: 0.992, green: 0.992, blue: 0.986)
    static let graphite = Color(red: 0.42, green: 0.42, blue: 0.39)
    static let line = Color(red: 0.12, green: 0.12, blue: 0.11)
    static let quietLine = Color(red: 0.86, green: 0.86, blue: 0.82)
    static let sky = Color(red: 0.32, green: 0.63, blue: 0.94)
    static let coral = Color(red: 0.95, green: 0.36, blue: 0.32)
    static let sunflower = Color(red: 1.0, green: 0.80, blue: 0.18)
    static let mint = Color(red: 0.40, green: 0.79, blue: 0.61)
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
                .stroke(AppColor.line.opacity(0.035), lineWidth: 1)
                .padding(10)
        }
        .ignoresSafeArea()
    }
}

struct PaperGridBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 42

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
            .offset(y: isVisible ? 0 : 6)
            .animation(.snappy(duration: 0.16), value: isVisible)
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
    let size: CGFloat
    let cornerRadius: CGFloat

    init(size: CGFloat = 52, cornerRadius: CGFloat = 14) {
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Image("BrandIcon")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .background(AppColor.ink, in: RoundedRectangle(cornerRadius: cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColor.line.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: AppColor.ink.opacity(0.08), radius: 10, y: 6)
    }
}
