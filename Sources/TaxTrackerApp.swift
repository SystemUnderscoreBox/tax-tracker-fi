import SwiftData
import SwiftUI

@main
struct TaxTrackerApp: App {

    // We configure a shared model container to handle Dev vs Production data
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

                // We will write a function later to inject fictional transactions here
                // e.g., generating mock trades for Gofore or Nordnet Suomi Indeksi
                // so you have immediate data to test the UI and tax algorithms.

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
            // This is the main view of the app.
            // It will show an error right now because we haven't created it yet!
            ContentView()
        }
        // This attaches our database configuration to the entire app
        .modelContainer(sharedModelContainer)
    }
}
