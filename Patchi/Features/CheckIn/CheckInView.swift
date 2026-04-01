import SwiftUI
import PhotosUI

struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CheckInViewModel()

    var body: some View {
        ZStack {
            // Fond couleur humeur
            Color.mood(score: viewModel.moodScore)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: viewModel.moodScore)

            VStack(spacing: 0) {
                // Header
                checkInHeader

                // Contenu par étape
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
                .animation(.easeInOut(duration: 0.4), value: viewModel.currentStep)

                // Footer avec boutons
                checkInFooter
            }
        }
        // L'utilisateur ferme manuellement via le bouton "Fermer"
    }

    // MARK: - Header

    private var checkInHeader: some View {
        HStack {
            Button {
                if viewModel.currentStep == .mood {
                    dismiss()
                } else {
                    viewModel.goBack()
                }
            } label: {
                Image(systemName: viewModel.currentStep == .mood ? "xmark" : "chevron.left")
                    .font(.title3)
                    .fontWeight(.medium)
            }

            Spacer()

            // Indicateur de progression
            HStack(spacing: 6) {
                ForEach(CheckInViewModel.Step.allCases, id: \.rawValue) { step in
                    Capsule()
                        .fill(step.rawValue <= viewModel.currentStep.rawValue ? Color.white : Color.white.opacity(0.3))
                        .frame(width: step.rawValue <= viewModel.currentStep.rawValue ? 20 : 8, height: 4)
                }
            }

            Spacer()

            // Espace pour équilibrer
            Color.clear.frame(width: 28, height: 28)
        }
        .foregroundStyle(Color.moodText(score: viewModel.moodScore))
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Step 1: Mood

    private var moodStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Comment tu te sens ?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.moodText(score: viewModel.moodScore))

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
                        .font(.headline)
                    TextField("Optionnel", text: $viewModel.title)
                        .textFieldStyle(.roundedBorder)
                }

                // Note libre
                VStack(alignment: .leading, spacing: 8) {
                    Text("Raconte ta journée")
                        .font(.headline)
                    TextEditor(text: $viewModel.note)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color(.systemGray4), lineWidth: 1)
                        }
                }

                // Photo optionnelle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Une photo ?")
                        .font(.headline)

                    if let photoData = viewModel.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
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

            PatchiWithBubble(
                expression: PatchiExpression.fromMoodScore(viewModel.moodScore),
                text: viewModel.reformulationText,
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Sauvegarder automatiquement quand on arrive sur la reformulation
            viewModel.save(context: modelContext)
        }
    }

    // MARK: - Footer

    private var checkInFooter: some View {
        Group {
            if viewModel.currentStep == .reformulation {
                Button {
                    dismiss()
                } label: {
                    Text("Fermer")
                        .font(.headline)
                        .foregroundStyle(Color.mood(score: viewModel.moodScore))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.moodText(score: viewModel.moodScore))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            } else {
                Button {
                    viewModel.goNext()
                } label: {
                    Text(viewModel.isLastInputStep ? "Terminer" : "Suivant")
                        .font(.headline)
                        .foregroundStyle(Color.mood(score: viewModel.moodScore))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.moodText(score: viewModel.moodScore))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                // Skip pour les étapes optionnelles
                if viewModel.currentStep != .mood {
                    Button("Passer") {
                        viewModel.goNext()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.moodText(score: viewModel.moodScore).opacity(0.6))
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CheckInView()
        .modelContainer(for: [CheckIn.self])
}
