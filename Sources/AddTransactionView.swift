import SwiftData
import SwiftUI

struct AddTransactionView: View {
    // 1. Access the database environment to save data and close the sheet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 2. State variables to hold the user's input before saving
    @State private var assetName: String = ""
    @State private var date: Date = Date()
    @State private var type: TransactionType = .buy
    @State private var pricePerShare: Double = 0.0
    @State private var quantity: Double = 0.0
    @State private var fees: Double = 0.0

    var body: some View {
        NavigationStack {
            // 3. Form creates a native, structured layout for inputs
            Form {
                Section("Asset Details") {
                    TextField("Asset Name (e.g., Gofore)", text: $assetName)

                    Picker("Type", selection: $type) {
                        Text("Buy").tag(TransactionType.buy)
                        Text("Sell").tag(TransactionType.sell)
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Transaction Date", selection: $date, displayedComponents: .date)
                }

                Section("Financial Details") {
                    // Using value: and format: ensures the TextField only accepts numbers
                    TextField("Price per Share (€)", value: $pricePerShare, format: .number)
                    TextField("Quantity (Shares)", value: $quantity, format: .number)
                    TextField("Brokerage Fees (€)", value: $fees, format: .number)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Transaction")
            .toolbar {
                // 4. Toolbar buttons for Cancel and Save
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    // Disable the save button if the asset name is empty
                    .disabled(assetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
        }
        // Give the sheet a minimum size so it doesn't look squished on a Mac
        .frame(minWidth: 400, minHeight: 450)
    }

    // 5. The save logic
    private func saveTransaction() {
        let newTransaction = Transaction(
            assetName: assetName,
            date: date,
            type: type,
            pricePerShare: pricePerShare,
            quantity: quantity,
            fees: fees
        )

        // Insert into the database
        modelContext.insert(newTransaction)

        // Close the sheet
        dismiss()
    }
}
