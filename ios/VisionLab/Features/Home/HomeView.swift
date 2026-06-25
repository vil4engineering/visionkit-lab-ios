import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("VisionKit Lab")
                    .font(.largeTitle.weight(.bold))
                Text("Identify and extract information using the device camera.")
                    .font(Theme.FontRole.caption)
                    .foregroundStyle(.secondary)
                featureCards
            }
            .padding(Theme.Spacing.md)
        }
        .navigationTitle("VisionKit Lab")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var featureCards: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(HomeDestination.allFeatures, id: \.id) { destination in
                NavigationLink(value: destination) {
                    HomeCard(
                        title: destination.title,
                        subtitle: destination.subtitle,
                        iconName: destination.iconName
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct HomeCard: View {
    let title: String
    let subtitle: String
    let iconName: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: iconName)
                .font(.title2)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.FontRole.cardTitle)
                Text(subtitle)
                    .font(Theme.FontRole.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(Theme.Spacing.md)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
