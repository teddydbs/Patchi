import SwiftUI
import SwiftData

struct AccountabilityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AccountabilityEntry.date, order: .reverse) private var entries: [AccountabilityEntry]
    @State private var viewModel = AccountabilityViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Rattrapage d'hier si nécessaire
                        if viewModel.hasMissedYesterday {
                            catchUpCard
                        }

                        // Question principale
                        questionSection

                        // Raison
                        if !viewModel.missedAction.isEmpty {
                            reasonSection
                        }

                        // Importance
                        if !viewModel.missedAction.isEmpty {
                            importanceSection
                        }

                        // Skip positif
                        skipButton

                        // Mini heatmap (30 derniers jours)
                        miniHeatmap
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Ce soir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        viewModel.save(context: modelContext)
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                viewModel.checkYesterday(entries: entries)
            }
            .overlay {
                if viewModel.showConfirmation {
                    confirmationOverlay
                }
            }
        }
    }

    // MARK: - Catch-up

    private var catchUpCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image("emotion_surpris")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                Text("Hier, qu'est-ce qui s'est passé ?")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.mdTextBlack)
                Spacer()
            }

            TextField("Ce que tu n'as pas fait hier...", text: $viewModel.missedAction, axis: .vertical)
                .dsTextField()
                .lineLimit(2...4)

            Button {
                viewModel.saveYesterdayCatchUp(context: modelContext)
            } label: {
                Text("Rattraper hier")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.mdTextBlack)
                    )
            }
            .disabled(viewModel.missedAction.isEmpty)
            .opacity(viewModel.missedAction.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdOrangeBg)
        )
    }

    // MARK: - Question

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            EmotionBubble(
                emotion: .confus,
                text: "Qu'aurais-tu aimé faire aujourd'hui que tu n'as pas fait ?",
                size: .medium,
                style: .standard
            )
            .frame(maxWidth: .infinity)

            TextEditor(text: $viewModel.missedAction)
                .frame(minHeight: 80)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(Color.mdBgSubtle)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.mdBorder, lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    if viewModel.missedAction.isEmpty {
                        Text("Écris ici...")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }
                .textLimit($viewModel.missedAction)
        }
    }

    // MARK: - Raison

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pourquoi ?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.mdTextBlack)

            TextField("La raison (optionnel)", text: $viewModel.reason, axis: .vertical)
                .dsTextField()
                .lineLimit(2...4)

            if !viewModel.reason.isEmpty {
                Text("Cette raison est valable ?")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.mdTextBlack)

                HStack(spacing: 8) {
                    ReasonButton(
                        title: "Oui, valable",
                        isSelected: viewModel.isReasonValid == true,
                        color: Color.mdYellow
                    ) {
                        viewModel.isReasonValid = true
                    }

                    ReasonButton(
                        title: "Non, pas vraiment",
                        isSelected: viewModel.isReasonValid == false,
                        color: Color(red: 0.90, green: 0.30, blue: 0.30)
                    ) {
                        viewModel.isReasonValid = false
                    }
                }
            }
        }
    }

    // MARK: - Importance

    private var importanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Importance")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.mdTextBlack)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        viewModel.importance = star
                        Haptics.light()
                    } label: {
                        Image(systemName: star <= viewModel.importance ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(star <= viewModel.importance ? Color.mdYellow : Color.mdBorder)
                    }
                    .buttonStyle(SpringPressStyle())
                }
            }
        }
    }

    // MARK: - Skip

    private var skipButton: some View {
        Button {
            viewModel.saveSkip(context: modelContext)
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.mdGreen)
                Text("Aujourd'hui tout allait bien")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.mdGreenBg)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mini Heatmap

    private var miniHeatmap: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tes 30 derniers jours")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.mdTextBlack)

            let days = HeatmapService.generateHeatmap(from: entries, days: 30)
            HeatmapGridView(days: days, columns: 7, animated: false)
        }
    }

    // MARK: - Confirmation

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 12) {
                EmotionBubble(
                    emotion: .empathique,
                    text: "Merci de l'avoir noté. Demain est un autre jour.",
                    size: .large
                )

                Text("Touche pour fermer")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .onTapGesture { dismiss() }
        .transition(.opacity)
        .task {
            try? await Task.sleep(for: .milliseconds(2500))
            dismiss()
        }
    }
}

// MARK: - Reason Button

private struct ReasonButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? color.opacity(0.2) : Color.mdBgSubtle)
                )
                .foregroundStyle(isSelected ? color : Color.mdTextBlack)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(isSelected ? color : Color.mdBorder, lineWidth: isSelected ? 2 : 1)
                }
        }
        .buttonStyle(SpringPressStyle())
    }
}

// MARK: - Preview

#Preview {
    AccountabilityView()
        .modelContainer(for: [AccountabilityEntry.self])
}
