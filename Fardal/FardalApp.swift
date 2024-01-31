//
//  FardalApp.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import SwiftUI
import SwiftData

@main
@MainActor
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
        .modelContainer(
            for: [CollectionModel.self, ItemModel.self, ImageModel.self],
            isUndoEnabled: true
        )
    }
}
