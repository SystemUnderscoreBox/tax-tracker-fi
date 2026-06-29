import SwiftData
import SwiftUI

struct TaxSimulatorView: View {
    // 1. We need the modelContext to save the new transaction
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .forward) private var transactions: [Transaction]

    @State private var selectedAsset: String = ""
    @State private var sellQuantity: Double = 0.0
    @State private var sellPricePerShare: Double = 0.0
    @State private var sellFees: Double = 0.0
    @State private var sellDate: Date = Date()

    @State private var simulationResult: TaxSimulationResult? = nil

    // 2. New state variables for user feedback
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil

    var uniqueAssets: [String] {
        let assets = transactions.map { $0.assetName }
        return Array(Set(assets)).sorted()
    }

    // 3. A computed property to calculate the max available shares for the currently selected asset
    var maxAvailableShares: Double {
        guard !selectedAsset.isEmpty else { return 0 }
        let lots = TaxCalculator.calculateAvailableLots(for: selectedAsset, from: transactions)
        return lots.reduce(0) { $0 + $1.remainingQuantity }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Simulation Parameters") {
                    Picker("Select Asset", selection: $selectedAsset) {
                        Text("Select an asset").tag("")
                        ForEach(uniqueAssets, id: \.self) { asset in
                            Text(asset).tag(asset)
                        }
                    }
                    // Clear messages when you change the selected asset
                    .onChange(of: selectedAsset) { oldValue, newValue in
                        errorMessage = nil
                        successMessage = nil
                        simulationResult = nil
                    }

                    // Show the user how many shares they actually have
                    if !selectedAsset.isEmpty {
                        Text("Available to sell: \(maxAvailableShares, specifier: "%.0f") shares")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    TextField("Quantity to Sell", value: $sellQuantity, format: .number)
                    TextField(
                        "Estimated Price per Share (€)", value: $sellPricePerShare, format: .number)
                    TextField("Estimated Selling Fees (€)", value: $sellFees, format: .number)
                    DatePicker(
                        "Planned Sell Date", selection: $sellDate, displayedComponents: .date)
                }

                // Display error or success messages directly above the run button
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.callout)
                }
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundStyle(.green)
                        .font(.callout)
                }

                Section {
                    Button("Run Simulation") {
                        runSimulation()
                    }
                    .disabled(selectedAsset.isEmpty || sellQuantity <= 0)
                }

                if let result = simulationResult {
                    Section("Simulation Results") {
                        HStack {
                            Text("Total Taxable Profit")
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(result.totalTaxableProfit, specifier: "%.2f") €")
                                .fontWeight(.bold)
                                .foregroundStyle(result.totalTaxableProfit > 0 ? .red : .green)
                        }

                        ForEach(result.batchResults, id: \.originalBuyDate) { batch in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(
                                    "Shares from \(batch.originalBuyDate, format: .dateTime.year().month().day())"
                                )
                                .font(.subheadline)
                                .fontWeight(.semibold)

                                Text("Sold: \(batch.sharesSold, specifier: "%.0f")")
                                    .font(.caption)

                                Text("Method: \(batch.bestMethod)")
                                    .font(.caption)
                                    .foregroundStyle(.blue)

                                Text("Taxable Profit: \(batch.taxableProfit, specifier: "%.2f") €")
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }

                        // 4. A button to convert the simulation into permanent data
                        Button(action: saveSimulationAsTransaction) {
                            Label("Save as Actual Sale", systemImage: "tray.and.arrow.down.fill")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Tax Simulator")
        }
    }

    private func runSimulation() {
        successMessage = nil

        // 5. The Validation Check
        if sellQuantity > maxAvailableShares {
            errorMessage =
                "Error: You only have \(String(format: "%.0f", maxAvailableShares)) shares available. Cannot sell \(String(format: "%.0f", sellQuantity))."
            simulationResult = nil
            return
        }

        errorMessage = nil

        simulationResult = TaxCalculator.simulateSale(
            assetName: selectedAsset,
            sellQuantity: sellQuantity,
            sellPricePerShare: sellPricePerShare,
            sellFees: sellFees,
            sellDate: sellDate,
            allTransactions: transactions
        )
    }

    // 6. The Saving Logic
    private func saveSimulationAsTransaction() {
        let newSale = Transaction(
            assetName: selectedAsset,
            date: sellDate,
            type: .sell,
            pricePerShare: sellPricePerShare,
            quantity: sellQuantity,
            fees: sellFees
        )

        modelContext.insert(newSale)

        // Reset the form so it is ready for the next simulation
        simulationResult = nil
        sellQuantity = 0.0
        sellPricePerShare = 0.0
        sellFees = 0.0
        successMessage = "Sale saved to transactions successfully!"
    }
}
