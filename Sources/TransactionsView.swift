import SwiftData
import SwiftUI

struct TransactionsView: View {
    // 1. Access the database environment
    @Environment(\.modelContext) private var modelContext

    // 2. Fetch all transactions, sorted by newest first
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    var body: some View {
        NavigationStack {
            List {
                // 3. Loop through the transactions and display them
                ForEach(transactions) { transaction in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(transaction.assetName)
                                .font(.headline)
                            Spacer()
                            Text(transaction.type.rawValue)
                                .foregroundStyle(transaction.type == .buy ? .green : .red)
                                .fontWeight(.bold)
                        }

                        Text(
                            "\(transaction.quantity, specifier: "%.4f") shares @ \(transaction.pricePerShare, specifier: "%.2f") €"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Text(transaction.date, format: .dateTime.year().month().day())
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
                // 4. Enable swipe-to-delete (or right-click delete on Mac)
                .onDelete(perform: deleteTransactions)
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // We will trigger a sheet to add a transaction here in the next step
                        print("Add button clicked")
                    }) {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
        }
    }

    // 5. The deletion logic
    private func deleteTransactions(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(transactions[index])
        }
    }
}
