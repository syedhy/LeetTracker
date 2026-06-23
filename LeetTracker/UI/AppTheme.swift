import SwiftUI

enum AppColor {
    #if os(macOS)
    static let ink = Color(nsColor: .labelColor)
    static let paper = Color(nsColor: .windowBackgroundColor)
    static let paperWarm = Color(nsColor: .controlBackgroundColor)
    static let graphite = Color(nsColor: .secondaryLabelColor)
    static let line = Color(nsColor: .separatorColor)
    static let quietLine = Color(nsColor: .gridColor)
    #else
    static let ink = Color(uiColor: .label)
    static let paper = Color(uiColor: .systemBackground)
    static let paperWarm = Color(uiColor: .secondarySystemBackground)
    static let graphite = Color(uiColor: .secondaryLabel)
    static let line = Color(uiColor: .separator)
    static let quietLine = Color(uiColor: .systemGray4)
    #endif

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

            PaperGridBackdrop()
                .stroke(AppColor.line.opacity(0.06), lineWidth: 1)
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
