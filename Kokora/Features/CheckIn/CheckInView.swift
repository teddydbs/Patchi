import SwiftUI
import PhotosUI

struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CheckInViewModel()

    private var isMoodStep: Bool { viewModel.currentStep == .mood }

    var body: some View {
        ZStack {
            // Background: vivid mood color on mood step, white otherwise
            (isMoodStep ? Color.moodVivid(viewModel.moodScore) : Color.mdBg)
                .ignoresSafeArea()
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.moodScore)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentStep)

            VStack(spacing: 0) {
                checkInHeader

                TabView(selection: Binding(
                    get: { viewModel.currentStep },
                    set: { _ in }
                )) {
                    moodStep.tag(CheckInViewModel.Step.mood)
                    activitiesStep.tag(CheckInViewModel.Step.activities)
                    emotionsStep.tag(CheckInViewModel.Step.emotions)
                    detailsStep.tag(CheckInViewModel.Step.details)
                    reformulationStep.tag(CheckInViewModel.Step.reformulation)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentStep)

                checkInFooter
            }
        }
    }

    // MARK: - Header

    private var checkInHeader: some View {
        HStack {
            Button {
                Haptics.light()
                if viewModel.currentStep == .mood {
                    dismiss()
                } else {
                    viewModel.goBack()
                }
            } label: {
                Image(systemName: viewModel.currentStep == .mood ? "xmark" : "chevron.left")
                    .font(.title3.weight(.medium))
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Progress pills
            HStack(spacing: 6) {
                ForEach(CheckInViewModel.Step.allCases, id: \.rawValue) { step in
                    Capsule()
                        .fill(step.rawValue <= viewModel.currentStep.rawValue
                            ? headerForeground
                            : headerForeground.opacity(0.25))
                        .frame(width: step.rawValue <= viewModel.currentStep.rawValue ? 20 : 8, height: 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentStep)
                }
            }

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .foregroundStyle(headerForeground)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    /// White text on mood step, black on white steps
    private var headerForeground: Color {
        isMoodStep ? .white : .mdTextBlack
    }

    // MARK: - Step 1: Mood

    private var moodStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Comment tu te sens ?")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)

            MoodSliderView(moodScore: $viewModel.moodScore)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Step 2: Activities

    private var activitiesStep: some View {
        ScrollView {
            ActivityGridView(selected: $viewModel.selectedActivities)
                .padding(20)
        }
    }

    // MARK: - Step 3: Emotions

    private var emotionsStep: some View {
        ScrollView {
            EmotionGridView(selected: $viewModel.selectedEmotions)
                .padding(20)
        }
    }

    // MARK: - Step 4: Details

    private var detailsStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Titre optionnel
                VStack(alignment: .leading, spacing: 8) {
                    Text("Un titre pour ce moment ?")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mdTextBlack)
                    TextField("Optionnel", text: $viewModel.title)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.mdBgSubtle)
                        )
                }

                // Note libre
                VStack(alignment: .leading, spacing: 8) {
                    Text("Raconte ta journée")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mdTextBlack)
                    TextEditor(text: $viewModel.note)
                        .frame(minHeight: 120)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.mdBgSubtle)
                        )
                        .textLimit($viewModel.note)
                }

                // Photo optionnelle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Une photo ?")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mdTextBlack)

                    if let photoData = viewModel.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    viewModel.photoData = nil
                                    viewModel.selectedPhotoItem = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 2)
                                }
                                .padding(8)
                            }
                    } else {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images
                        ) {
                            Label("Ajouter une photo", systemImage: "photo.badge.plus")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color.mdTextGray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.mdBgSubtle)
                                )
                        }
                        .onChange(of: viewModel.selectedPhotoItem) {
                            Task { await viewModel.loadPhoto() }
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Step 5: Reformulation

    private var reformulationStep: some View {
        VStack(spacing: 32) {
            Spacer()

            EmotionBubble(
                emotion: viewModel.selectedEmotions.first ?? Emotion.forMoodScore(viewModel.moodScore),
                text: viewModel.reformulationText,
                size: .large,
                style: .emotional
            )

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            viewModel.save(context: modelContext)
        }
    }

    // MARK: - Footer

    private var checkInFooter: some View {
        Group {
            if viewModel.currentStep == .reformulation {
                // Black pill button for "Fermer"
                Button {
                    dismiss()
                } label: {
                    Text("Fermer")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.mdTextBlack)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            } else {
                VStack(spacing: 8) {
                    if viewModel.currentStep != .mood {
                        Button("Terminer maintenant") {
                            viewModel.finishEarly()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.mdTextGray)
                    }

                    Button {
                        Haptics.medium()
                        viewModel.goNext()
                    } label: {
                        Text(viewModel.isLastInputStep ? "Terminer" : "Suivant")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isMoodStep ? Color.white.opacity(0.3) : Color.mdGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .foregroundStyle(isMoodStep ? .white : .white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    CheckInView()
        .modelContainer(for: [CheckIn.self])
}
