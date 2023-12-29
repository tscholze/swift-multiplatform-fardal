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
        .modelContainer(appContainer)
    }

    // MARK: - Swift Data setup -

    let appContainer: ModelContainer = {
        do {
            // Build schema with all sotred models
            let schema = Schema([
                CollectionModel.self,
                ItemModel.self,
                ImageModel.self,
                ItemCustomAttribute.self,
                TagModel.self,
            ])

            // Make SwiftData configuration
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            // Make container based on schema and configuration
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            // How to add default values
            // // Make fetcher to check if all required system collections exists.
            // var fetchDescriptor = FetchDescriptor<CollectionModel>()
            // let title = FardalConstants.Collection.systemUnlinkedItemsCollectionTitle
            // fetchDescriptor.predicate = #Predicate { $0.title == title }
            //
            // // TODO: Why does this not work?
            // // fetchDescriptor.predicate = #Predicate { $0.title == FardalConstants.Collection.systemUnlinkedItemsCollectionTitle }
            //
            // // Perform fetch
            // // If at least one collection exists, than return container
            // // Else add system-required models.
            // guard try container.mainContext.fetch(fetchDescriptor).count == 0 else {
            //    return container
            // }
            //
            // let systemCollection = CollectionModel(
            //    coverImageData: CollectionModel.makeSystemCoverImageData(),
            //    title: FardalConstants.Collection.systemUnlinkedItemsCollectionTitle,
            //    summary: "",
            //    items: []
            // )
            //
            // container.mainContext.insert(systemCollection)
            //
            return container
        }
        catch {
            fatalError("Failed to create container")
        }
    }()
}

extension FardalApp {}
