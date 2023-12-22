//
//  FardalApp.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import SwiftUI
import SwiftData

@main
struct FardalApp: App {
    // MARK: - Properties -

    @AppStorage("appereance")
    private var currentAppearance: Appereance = .system

    // MARK: - UI -

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(currentAppearance.scheme)
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Swift Data setup -

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ItemModel.self,
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

extension FardalApp {}
