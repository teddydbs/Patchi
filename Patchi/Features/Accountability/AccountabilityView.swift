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
                Color.dsBackground.ignoresSafeArea()
                BlobBackground(colors: [.accentPurple, .patchiOrange], opacity: 0.08)

                ScrollView {
                    VStack(spacing: DS.Spacing.xl) {
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
                    .padding(DS.Spacing.lg)
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
        ClayCard(tint: .patchiOrange) {
            VStack(spacing: DS.Spacing.md) {
                HStack {
                    PatchiView(expression: .curious, size: .small)
                    Text("Hier, qu'est-ce qui s'est passé ?")
                        .font(.system(size: DS.Font.body, weight: .medium))
                        .foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                }

                TextField("Ce que tu n'as pas fait hier...", text: $viewModel.missedAction, axis: .vertical)
                    .dsTextField()
                    .lineLimit(2...4)

                PillButton(title: "Rattraper hier", style: .secondary) {
                    viewModel.saveYesterdayCatchUp(context: modelContext)
                }
                .disabled(viewModel.missedAction.isEmpty)
                .opacity(viewModel.missedAction.isEmpty ? 0.5 : 1)
            }
        }
    }

    // MARK: - Question

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            PatchiWithBubble(
                expression: .thinking,
                text: "Qu'aurais-tu aimé faire aujourd'hui que tu n'as pas fait ?",
                patchiSize: .medium,
                bubbleStyle: .standard
            )
            .frame(maxWidth: .infinity)

            TextEditor(text: $viewModel.missedAction)
                .frame(minHeight: 80)
                .padding(10)
                .background(Color.dsCard)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.dsBorder, lineWidth: 1)
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
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Pourquoi ?")
                .font(.system(size: DS.Font.body, weight: .semibold))
                .foregroundStyle(Color.dsTextPrimary)

            TextField("La raison (optionnel)", text: $viewModel.reason, axis: .vertical)
                .dsTextField()
                .lineLimit(2...4)

            if !viewModel.reason.isEmpty {
                Text("Cette raison est valable ?")
                    .font(.system(size: DS.Font.body, weight: .medium))
                    .foregroundStyle(Color.dsTextPrimary)

                HStack(spacing: DS.Spacing.sm) {
                    ReasonButton(
                        title: "Oui, valable",
                        isSelected: viewModel.isReasonValid == true,
                        color: .accentAmber
                    ) {
                        viewModel.isReasonValid = true
                    }

                    ReasonButton(
                        title: "Non, pas vraiment",
                        isSelected: viewModel.isReasonValid == false,
                        color: .dsDestructive
                    ) {
                        viewModel.isReasonValid = false
                    }
                }
            }
        }
    }

    // MARK: - Importance

    private var importanceSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Importance")
                .font(.system(size: DS.Font.body, weight: .semibold))
                .foregroundStyle(Color.dsTextPrimary)

            HStack(spacing: DS.Spacing.sm) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        viewModel.importance = star
                        Haptics.light()
                    } label: {
                        Image(systemName: star <= viewModel.importance ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(star <= viewModel.importance ? Color.accentAmber : Color.dsBorder)
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
                    .foregroundStyle(.green)
                Text("Aujourd'hui tout allait bien")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.dsCard)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mini Heatmap

    private var miniHeatmap: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Tes 30 derniers jours")
                .font(.system(size: DS.Font.body, weight: .semibold))
                .foregroundStyle(Color.dsTextPrimary)

            let days = HeatmapService.generateHeatmap(from: entries, days: 30)
            HeatmapGridView(days: days, columns: 7, animated: false)
        }
    }

    // MARK: - Confirmation

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: DS.Spacing.md) {
                PatchiWithBubble(
                    expression: .happy,
                    text: "C'est noté. Reviens demain.",
                    patchiSize: .large
                )

                Text("Touche pour fermer")
                    .font(.system(size: DS.Font.caption))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .onTapGesture { dismiss() }
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
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
                .font(.system(size: DS.Font.body, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(isSelected ? color.opacity(0.15) : Color.dsCard)
                .foregroundStyle(isSelected ? color : Color.dsTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                        .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
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
