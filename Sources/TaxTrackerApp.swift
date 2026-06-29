import AppKit
import SwiftData
import SwiftUI

@main
struct TaxTrackerApp: App {

    // Add this initialization block to force foreground application behavior
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self
        ])

        #if DEBUG
            // DEVELOPMENT MODE: In-memory database that resets on every launch
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

            do {
                let container = try ModelContainer(
                    for: schema, configurations: [modelConfiguration])
                let context = container.mainContext

                // Generate a recent fictional purchase (under 10 years)
                let techCorpBuy = Transaction(
                    assetName: "TechCorp",
                    date: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                    type: .buy,
                    pricePerShare: 150.00,
                    quantity: 50.0,
                    fees: 8.0
                )

                // Generate an older fictional purchase (over 10 years to test hankintameno-olettama)
                let globalIndexBuy = Transaction(
                    assetName: "Global Index Fund",
                    date: Calendar.current.date(byAdding: .year, value: -12, to: Date()) ?? Date(),
                    type: .buy,
                    pricePerShare: 45.00,
                    quantity: 200.0,
                    fees: 0.0
                )

                // Insert the fictional data into the development database
                context.insert(techCorpBuy)
                context.insert(globalIndexBuy)

                return container
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }

        #else
            // PRODUCTION MODE: Persistent storage on the hard drive
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 900, height: 600)
        .modelContainer(sharedModelContainer)
    }
}
