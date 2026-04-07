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
            HStack(spacing: DS.Spacing.sm) {
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
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.sm)
        }
        .background(.ultraThinMaterial)
        .safeAreaPadding(.top)
    }
}

// MARK: - Quote Card (plein écran)

private struct QuoteCardView: View {
    let quote: Quote
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onShare: () -> Void

    private var gradientColors: [Color] {
        switch quote.category {
        case .courage: [Color(red: 0.15, green: 0.15, blue: 0.35), Color(red: 0.25, green: 0.2, blue: 0.5)]
        case .decision: [Color(red: 0.2, green: 0.12, blue: 0.35), Color(red: 0.35, green: 0.15, blue: 0.45)]
        case .soi: [Color(red: 0.1, green: 0.2, blue: 0.35), Color(red: 0.15, green: 0.3, blue: 0.45)]
        case .relations: [Color(red: 0.3, green: 0.15, blue: 0.2), Color(red: 0.4, green: 0.2, blue: 0.3)]
        case .travail: [Color(red: 0.15, green: 0.2, blue: 0.25), Color(red: 0.2, green: 0.25, blue: 0.35)]
        case .nature: [Color(red: 0.1, green: 0.25, blue: 0.2), Color(red: 0.15, green: 0.35, blue: 0.25)]
        }
    }

    var body: some View {
        ZStack {
            // Fond gradient immersif (style Reflectly)
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Cercle décoratif subtil
            Circle()
                .fill(quote.category.color.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(y: -40)

            VStack(spacing: DS.Spacing.xxl) {
                Spacer()

                // Citation
                VStack(spacing: DS.Spacing.lg) {
                    Text("\u{201C}")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundStyle(.white.opacity(0.3))

                    Text(quote.text)
                        .font(.patchiQuote(26))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DS.Spacing.xxl)

                    HStack {
                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 32, height: 1)
                        Text(quote.author.uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.6))
                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 32, height: 1)
                    }
                }

                Spacer()

                // Actions
                HStack(spacing: DS.Spacing.xxl) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isFavorite ? .red : .white.opacity(0.7))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.white.opacity(0.1)))
                    }

                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.white.opacity(0.1)))
                    }
                }
                .padding(.bottom, DS.Spacing.xxl)
            }

            // Catégorie en bas à gauche
            VStack {
                Spacer()
                HStack {
                    Text(quote.category.displayName)
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1)
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.white.opacity(0.12)))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.lg)
            }
        }
    }
}

