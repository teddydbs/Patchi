import SwiftUI
import PhotosUI

struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CheckInViewModel()

    var body: some View {
        ZStack {
            // Fond couleur humeur + blobs
            Color.mood(score: viewModel.moodScore)
                .ignoresSafeArea()
                .animation(DS.Animation.screen, value: viewModel.moodScore)

            BlobBackground(
                colors: [
                    Color.mood(score: viewModel.moodScore).opacity(0.5),
                    .patchiOrange.opacity(0.3)
                ],
                opacity: 0.2,
                blurRadius: 80
            )

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
                .animation(DS.Animation.screen, value: viewModel.currentStep)

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
                let textColor = Color.moodText(score: viewModel.moodScore)
                ForEach(CheckInViewModel.Step.allCases, id: \.rawValue) { step in
                    Capsule()
                        .fill(step.rawValue <= viewModel.currentStep.rawValue
                            ? textColor
                            : textColor.opacity(0.25))
                        .frame(width: step.rawValue <= viewModel.currentStep.rawValue ? 20 : 8, height: 4)
                        .animation(DS.Animation.micro, value: viewModel.currentStep)
                }
            }

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .foregroundStyle(Color.moodText(score: viewModel.moodScore))
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, DS.Spacing.sm)
    }

    // MARK: - Step 1: Mood

    private var moodStep: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()

            Text("Comment tu te sens ?")
                .font(.patchiTitle(28))
                .foregroundStyle(Color.moodText(score: viewModel.moodScore))

            MoodSliderView(moodScore: $viewModel.moodScore)

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Step 2: Activities

    private var activitiesStep: some View {
        ScrollView {
            ActivityGridView(selected: $viewModel.selectedActivities)
                .padding(DS.Spacing.lg)
        }
    }

    // MARK: - Step 3: Emotions

    private var emotionsStep: some View {
        ScrollView {
            EmotionGridView(selected: $viewModel.selectedEmotions)
                .padding(DS.Spacing.lg)
        }
    }

    // MARK: - Step 4: Details

    private var detailsStep: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                // Titre optionnel
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Un titre pour ce moment ?")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.moodText(score: viewModel.moodScore))
                    TextField("Optionnel", text: $viewModel.title)
                        .padding(DS.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                                .fill(Color.white.opacity(0.2))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                }

                // Note libre
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Raconte ta journée")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.moodText(score: viewModel.moodScore))
                    TextEditor(text: $viewModel.note)
                        .frame(minHeight: 120)
                        .padding(DS.Spacing.sm)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                                .fill(Color.white.opacity(0.2))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                        .textLimit($viewModel.note)
                }

                // Photo optionnelle
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Une photo ?")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.moodText(score: viewModel.moodScore))

                    if let photoData = viewModel.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous))
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
                                .padding(DS.Spacing.sm)
                            }
                    } else {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images
                        ) {
                            Label("Ajouter une photo", systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                                        .fill(Color.white.opacity(0.15))
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                }
                        }
                        .onChange(of: viewModel.selectedPhotoItem) {
                            Task { await viewModel.loadPhoto() }
                        }
                    }
                }
            }
            .padding(DS.Spacing.lg)
        }
    }

    // MARK: - Step 5: Reformulation

    private var reformulationStep: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()

            PatchiWithBubble(
                expression: PatchiExpression.fromMoodScore(viewModel.moodScore),
                text: viewModel.reformulationText,
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            Spacer()
        }
        .padding(.horizontal, DS.Spacing.lg)
        .onAppear {
            viewModel.save(context: modelContext)
        }
    }

    // MARK: - Footer

    private var checkInFooter: some View {
        Group {
            if viewModel.currentStep == .reformulation {
                PillButton(title: "Fermer", style: .mood(viewModel.moodScore)) {
                    dismiss()
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, 30)
            } else {
                VStack(spacing: DS.Spacing.sm) {
                    if viewModel.currentStep != .mood {
                        Button("Terminer maintenant") {
                            viewModel.finishEarly()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.moodText(score: viewModel.moodScore).opacity(0.5))
                    }

                    Button {
                        Haptics.medium()
                        viewModel.goNext()
                    } label: {
                        Text(viewModel.isLastInputStep ? "Terminer" : "Suivant")
                            .font(.headline)
                            .foregroundStyle(Color.mood(score: viewModel.moodScore))
                            .frame(maxWidth: .infinity)
                            .frame(height: DS.buttonHeight)
                            .background(Color.moodText(score: viewModel.moodScore))
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button, style: .continuous))
                    }
                    .buttonStyle(SpringPressStyle())
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    CheckInView()
        .modelContainer(for: [CheckIn.self])
}
