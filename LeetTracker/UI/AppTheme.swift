import SwiftUI

enum AppColor {
    // Doodle Theme Colors
    static let ink = Color(red: 0.11, green: 0.11, blue: 0.11)
    static let paper = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let paperWarm = Color(red: 0.96, green: 0.95, blue: 0.90)
    static let graphite = Color.gray
    static let line = ink
    static let quietLine = ink.opacity(0.1)

    static let sky = Color.blue
    static let coral = Color.red
    static let sunflower = Color.yellow
    static let mint = Color.green
    
    static let brand = ink
    static let easy = Color.green
    static let medium = Color.orange
    static let hard = Color.red
}

struct AppSurfaceBackground: View {
    var body: some View {
        ZStack {
            AppColor.paperWarm

            DotGridBackdrop()
                .fill(AppColor.ink.opacity(0.1))
                .padding(10)
        }
        .ignoresSafeArea()
    }
}

struct DotGridBackdrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 24
        let dotSize: CGFloat = 2
        
        var y = rect.minY
        while y <= rect.maxY {
            var x = rect.minX
            while x <= rect.maxX {
                path.addEllipse(in: CGRect(x: x, y: y, width: dotSize, height: dotSize))
                x += step
            }
            y += step
        }
        return path
    }
}

// MARK: - Doodle Style Modifiers

struct DoodlePanelStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    var shadowOffset: CGFloat = 4

    func body(content: Content) -> some View {
        content
            .background(AppColor.paper)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColor.ink, lineWidth: 3)
            }
            .shadow(color: AppColor.ink, radius: 0, x: shadowOffset, y: shadowOffset)
    }
}

extension View {
    func doodlePanel(cornerRadius: CGFloat = 16, shadowOffset: CGFloat = 4) -> some View {
        modifier(DoodlePanelStyle(cornerRadius: cornerRadius, shadowOffset: shadowOffset))
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
