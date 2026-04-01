import SwiftUI
import SwiftData

struct AccountabilityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AccountabilityEntry.date, order: .reverse) private var entries: [AccountabilityEntry]
    @State private var viewModel = AccountabilityViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
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
                PatchiView(expression: .curious, size: .small)
                Text("Hier, qu'est-ce qui s'est passé ?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }

            TextField("Ce que tu n'as pas fait hier...", text: $viewModel.missedAction, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            Button("Rattraper hier") {
                viewModel.saveYesterdayCatchUp(context: modelContext)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .disabled(viewModel.missedAction.isEmpty)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.patchiOrange.opacity(0.08))
        }
    }

    // MARK: - Question

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
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
        }
    }

    // MARK: - Raison

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pourquoi ?")
                .font(.headline)

            TextField("La raison (optionnel)", text: $viewModel.reason, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            if !viewModel.reason.isEmpty {
                Text("Cette raison est valable ?")
                    .font(.subheadline)

                HStack(spacing: 12) {
                    ReasonButton(
                        title: "Oui, valable",
                        isSelected: viewModel.isReasonValid == true,
                        color: .orange
                    ) {
                        viewModel.isReasonValid = true
                    }

                    ReasonButton(
                        title: "Non, pas vraiment",
                        isSelected: viewModel.isReasonValid == false,
                        color: .red
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
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        viewModel.importance = star
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: star <= viewModel.importance ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(star <= viewModel.importance ? .orange : Color(.systemGray3))
                    }
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
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mini Heatmap

    private var miniHeatmap: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tes 30 derniers jours")
                .font(.headline)

            let days = HeatmapService.generateHeatmap(from: entries, days: 30)
            HeatmapGridView(days: days, columns: 7, animated: false)
        }
    }

    // MARK: - Confirmation

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 16) {
                PatchiWithBubble(
                    expression: .happy,
                    text: "C'est noté. Reviens demain.",
                    patchiSize: .large
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    dismiss()
                }
            }
        }
        .transition(.opacity)
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
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? color.opacity(0.15) : Color(.systemGray6))
                .foregroundStyle(isSelected ? color : .primary)
                .cornerRadius(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    AccountabilityView()
        .modelContainer(for: [AccountabilityEntry.self])
}
