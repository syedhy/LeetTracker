import SwiftUI

enum AppColor {
    // Doodle Theme Colors
    static let ink = Color(red: 0.10, green: 0.10, blue: 0.11)
    static let paper = Color(red: 0.94, green: 0.92, blue: 0.86)
    static let paperWarm = Color(red: 1.00, green: 0.99, blue: 0.95)
    static let graphite = Color(red: 0.60, green: 0.60, blue: 0.65)
    static let line = ink
    static let quietLine = ink.opacity(0.1)

    // Vibrant Doodle Accents
    static let sky = Color(red: 0.35, green: 0.70, blue: 1.00)
    static let coral = Color(red: 1.00, green: 0.40, blue: 0.40)
    static let sunflower = Color(red: 1.00, green: 0.85, blue: 0.25)
    static let mint = Color(red: 0.35, green: 0.90, blue: 0.65)
    static let pink = Color(red: 1.00, green: 0.40, blue: 0.70)
    static let orange = Color(red: 1.00, green: 0.55, blue: 0.15)
    static let purple = Color(red: 0.65, green: 0.40, blue: 1.00)
    static let gray = graphite
    
    static let brand = ink
    static let easy = mint
    static let medium = orange
    static let hard = coral
}

struct AppSurfaceBackground: View {
    var body: some View {
        ZStack {
            AppColor.paper

            DoodlePaperBackground()
                .stroke(AppColor.ink.opacity(0.045), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

struct DoodlePaperBackground: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 28
        
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

// MARK: - Doodle Style Modifiers

struct DoodlePanelStyle: ViewModifier {
    var cornerRadius: CGFloat = 24
    var shadowOffset: CGFloat = 4 // Kept parameter for API compatibility

    func body(content: Content) -> some View {
        content
            .background(AppColor.paper)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColor.ink, lineWidth: 3)
            }
            .shadow(color: AppColor.ink.opacity(0.15), radius: 0, x: 5, y: 6)
    }
}

extension View {
    func doodlePanel(cornerRadius: CGFloat = 24, shadowOffset: CGFloat = 4) -> some View {
        modifier(DoodlePanelStyle(cornerRadius: cornerRadius, shadowOffset: shadowOffset))
    }
    
    func doodleFont() -> some View {
        self.fontDesign(.rounded).fontWeight(.black)
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
