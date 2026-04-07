import SwiftUI

struct BlobBackground: View {
    var colors: [Color] = [.patchiOrange, .accentPurple, .accentAmber]
    var opacity: Double = 0.15
    var blurRadius: CGFloat = 70

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Blob 1 — top trailing
                Circle()
                    .fill(colors[0 % colors.count])
                    .frame(width: geo.size.width * 0.6)
                    .offset(
                        x: geo.size.width * 0.25 + (animate ? 20 : -20),
                        y: -geo.size.height * 0.1 + (animate ? 15 : -15)
                    )

                // Blob 2 — center leading
                Ellipse()
                    .fill(colors[1 % colors.count])
                    .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.4)
                    .offset(
                        x: -geo.size.width * 0.2 + (animate ? -15 : 15),
                        y: geo.size.height * 0.25 + (animate ? 20 : -20)
                    )

                // Blob 3 — bottom center
                if colors.count > 2 {
                    Circle()
                        .fill(colors[2])
                        .frame(width: geo.size.width * 0.45)
                        .offset(
                            x: geo.size.width * 0.05 + (animate ? 10 : -10),
                            y: geo.size.height * 0.55 + (animate ? -18 : 18)
                        )
                }
            }
            .opacity(opacity)
            .blur(radius: blurRadius)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(DS.Animation.blobDrift) {
                animate = true
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Mood-aware variant

extension BlobBackground {
    static func forMood(_ score: Int) -> BlobBackground {
        let moodColor = Color.mood(score: score)
        return BlobBackground(
            colors: [moodColor, .patchiOrange, moodColor.opacity(0.6)],
            opacity: 0.12
        )
    }
}

// MARK: - Preview

#Preview("BlobBackground") {
    ZStack {
        Color.dsBackground
        BlobBackground()

        VStack {
            Text("Contenu au-dessus")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.dsTextPrimary)
        }
    }
}
