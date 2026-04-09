import SwiftUI
import SwiftData

struct QuotesFeedView: View {
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @State private var viewModel = QuotesViewModel()

    var body: some View {
        ZStack {
            // Feed swipeable plein écran
            TabView(selection: $viewModel.currentIndex) {
                let quotes = viewModel.filteredQuotes(latestMoodScore: checkIns.first?.moodScore)
                ForEach(Array(quotes.enumerated()), id: \.element.id) { index, quote in
                    QuoteCardView(
                        quote: quote,
                        isFavorite: viewModel.favorites.contains(quote.id),
                        onToggleFavorite: { viewModel.toggleFavorite(quote.id) },
                        onShare: { viewModel.shareQuote(quote) }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Filtres en haut
            VStack {
                filterBar
                Spacer()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipDS(label: "Tout", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                    viewModel.clearCache()
                }

                ForEach(QuoteCategory.allCases) { category in
                    FilterChipDS(
                        label: category.displayName,
                        isSelected: viewModel.selectedCategory == category,
                        color: category.color
                    ) {
                        viewModel.selectedCategory = category
                        viewModel.clearCache()
                    }
                }

                FilterChipDS(label: "Favoris", icon: "heart.fill", isSelected: false) {
                    // TODO: Vue favoris
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(Color.white.opacity(0.85))
        .safeAreaPadding(.top)
    }
}

// MARK: - Quote Card (plein écran)

private struct QuoteCardView: View {
    let quote: Quote
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onShare: () -> Void

    /// Vivid solid background color per category
    private var backgroundColor: Color {
        switch quote.category {
        case .courage:   Color(red: 1.0, green: 0.72, blue: 0.55)   // warm orange-peach
        case .decision:  Color(red: 0.55, green: 0.73, blue: 0.95)  // calm blue
        case .soi:       Color(red: 0.75, green: 0.65, blue: 0.92)  // soft purple
        case .relations: Color(red: 0.97, green: 0.60, blue: 0.65)  // warm pink
        case .travail:   Color(red: 0.45, green: 0.85, blue: 0.58)  // fresh green
        case .nature:    Color(red: 0.55, green: 0.88, blue: 0.78)  // mint green
        }
    }

    var body: some View {
        ZStack {
            // Fond vivid solid
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Citation
                VStack(spacing: 20) {
                    Text("\u{201C}")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundStyle(.white.opacity(0.5))

                    Text(quote.text)
                        .font(.patchiQuote(26))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)

                    HStack {
                        Rectangle()
                            .fill(.white.opacity(0.4))
                            .frame(width: 32, height: 1)
                        Text(quote.author.uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.8))
                        Rectangle()
                            .fill(.white.opacity(0.4))
                            .frame(width: 32, height: 1)
                    }
                }

                Spacer()

                // Actions — white circles
                HStack(spacing: 32) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isFavorite ? .red : .white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.white.opacity(0.25)))
                    }

                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.white.opacity(0.25)))
                    }
                }
                .padding(.bottom, 32)
            }

            // Catégorie en bas à gauche
            VStack {
                Spacer()
                HStack {
                    Text(quote.category.displayName)
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.white.opacity(0.25)))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
