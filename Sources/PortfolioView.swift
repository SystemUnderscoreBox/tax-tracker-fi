import SwiftData
import SwiftUI

struct PortfolioView: View {
    // 1. Fetch all transactions to process through our engine
    @Query(sort: \Transaction.date, order: .forward) private var transactions: [Transaction]

    // 2. A computed property that processes history and builds a summary of current holdings
    var portfolioAssets: [(name: String, shares: Double, averagePrice: Double)] {
        // Find all unique stock names
        let assetNames = Array(Set(transactions.map { $0.assetName })).sorted()

        var assetsSummary: [(String, Double, Double)] = []

        for name in assetNames {
            // 3. Use the TaxCalculator engine to get the current un-sold lots
            let availableLots = TaxCalculator.calculateAvailableLots(for: name, from: transactions)

            // Sum up the remaining shares
            let totalShares = availableLots.reduce(0) { $0 + $1.remainingQuantity }

            // If we actually still own shares of this asset, calculate the average price
            if totalShares > 0 {
                let totalCost = availableLots.reduce(0) {
                    $0 + ($1.remainingQuantity * $1.buyPricePerShare)
                }
                let averagePrice = totalCost / totalShares

                assetsSummary.append((name, totalShares, averagePrice))
            }
        }

        return assetsSummary
    }

    var body: some View {
        NavigationStack {
            List {
                // 4. Handle the empty state
                if portfolioAssets.isEmpty {
                    Text("No assets currently owned.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    // 5. Display each currently owned asset
                    ForEach(portfolioAssets, id: \.name) { asset in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(asset.name)
                                    .font(.headline)
                                Text("\(asset.shares, specifier: "%.4f") shares")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Avg Price: \(asset.averagePrice, specifier: "%.2f") €")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(
                                    "Invested: \((asset.shares * asset.averagePrice), specifier: "%.2f") €"
                                )
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Portfolio")
        }
    }
}
