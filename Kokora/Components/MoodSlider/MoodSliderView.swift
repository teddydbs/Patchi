import SwiftUI

struct MoodSliderView: View {
    @Binding var moodScore: Int
    @State private var sliderValue: Double = 3.0
    @State private var isDragging = false

    private let moodLabels = ["Très mal", "Mal", "Neutre", "Bien", "Très bien"]

    var body: some View {
        VStack(spacing: 24) {
            // Illustration d'émotion adaptée au score
            Image(Emotion.forMoodScore(moodScore).imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .scaleEffect(isDragging ? 1.08 : 1.0)
                .animation(.easeOut(duration: 0.2), value: isDragging)

            // Label d'humeur
            Text(moodLabels[safe: moodScore - 1] ?? "Neutre")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.moodText(score: moodScore))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: moodScore)

            // Slider custom
            VStack(spacing: 12) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)

                        // Track filled
                        Capsule()
                            .fill(Color.white.opacity(0.7))
                            .frame(
                                width: max(0, (sliderValue - 1) / 4 * geometry.size.width),
                                height: 8
                            )

                        // Thumb
                        Circle()
                            .fill(.white)
                            .frame(width: isDragging ? 36 : 30, height: isDragging ? 36 : 30)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                            .overlay {
                                Text(moodEmoji)
                                    .font(.system(size: isDragging ? 18 : 15))
                            }
                            .offset(x: thumbOffset(in: geometry.size.width))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        isDragging = true
                                        let newValue = 1.0 + (value.location.x / geometry.size.width) * 4.0
                                        sliderValue = min(max(newValue, 1.0), 5.0)
                                        let newScore = Int(sliderValue.rounded())
                                        if newScore != moodScore {
                                            moodScore = newScore
                                            hapticFeedback()
                                        }
                                    }
                                    .onEnded { _ in
                                        isDragging = false
                                        withAnimation(.spring(duration: 0.3)) {
                                            sliderValue = Double(moodScore)
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 36)

                // Marqueurs
                HStack {
                    ForEach(1...5, id: \.self) { score in
                        Text("\(score)")
                            .font(.caption2)
                            .fontWeight(score == moodScore ? .bold : .regular)
                            .foregroundStyle(Color.moodText(score: moodScore).opacity(score == moodScore ? 1 : 0.5))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.3)) {
                                    moodScore = score
                                    sliderValue = Double(score)
                                }
                                hapticFeedback()
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            sliderValue = Double(moodScore)
        }
    }

    private var moodEmoji: String {
        switch moodScore {
        case 1: "😞"
        case 2: "😔"
        case 3: "😐"
        case 4: "🙂"
        case 5: "😄"
        default: "😐"
        }
    }

    private func thumbOffset(in width: CGFloat) -> CGFloat {
        let progress = (sliderValue - 1) / 4
        let thumbRadius: CGFloat = isDragging ? 18 : 15
        return progress * (width - thumbRadius * 2)
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var mood = 3

        var body: some View {
            ZStack {
                Color.mood(score: mood)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.4), value: mood)

                MoodSliderView(moodScore: $mood)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}
