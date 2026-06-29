import Foundation
import SwiftData

// Defines whether the transaction is a purchase or a sale
enum TransactionType: String, Codable {
    case buy = "Buy"
    case sell = "Sell"
}

// The @Model macro tells SwiftData to save this object to the database
@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var assetName: String
    var date: Date
    var type: TransactionType
    var pricePerShare: Double
    var quantity: Double
    var fees: Double

    init(
        id: UUID = UUID(),
        assetName: String,
        date: Date,
        type: TransactionType,
        pricePerShare: Double,
        quantity: Double,
        fees: Double
    ) {

        self.id = id
        self.assetName = assetName
        self.date = date
        self.type = type
        self.pricePerShare = pricePerShare
        self.quantity = quantity
        self.fees = fees
    }
}
