import SwiftUI

@main
struct BobaTimeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalSearchService())
        }
    }
}
