//
//  DashboardView.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import SwiftData

/// The `DashboardView` provides a basic overview
/// over User's created elements.
struct DashboardView: View {
    // MARK: - Database properties -

    @Query(sort: \ItemModel.createdAt, order: .reverse)
    private var items: [ItemModel]

    @Query(sort: \CollectionModel.createdAt, order: .reverse)
    private var collections: [CollectionModel]

    // MARK: - States -

    @State var path = NavigationPath()

    // MARK: - UI -

    var body: some View {
        NavigationStack(path: $path) {
            List {
                makeCollectionsSection()
                makeLatestItemsSection()
            }
            .navigationTitle("Dashboard.Title")
            .navigationDestination(for: CollectionModel.self) { collection in
                CollectionDetailView(initialState: .read(collection))
            }
            .navigationDestination(for: ItemModel.self) { item in
                ItemDetailView(initialState: .read(item))
            }
        }
        .tabItem { Label("Dashboard.Title", systemSymbol: .house) }
    }
}

// MARK: - View builders -

extension DashboardView {
    @ViewBuilder
    private func makeCollectionsSection() -> some View {
        Section {
            HStack {
                if collections.isEmpty {
                    Hint(
                        titleKey: "Dashboard.Section.Collections.Empty.Hint",
                        systemName: "doc.on.doc",
                        size: .large
                    )
                }
                else {
                    ForEach(collections) { collection in
                        CollectionThumbnail(
                            collection: collection,
                            size: .large,
                            action: { path.append(collection) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } header: {
            HStack {
                Text("Dashboard.Section.LatestCollections.Title")
                Spacer()
                NavigationLink {
                    CollectionDetailView(initialState: .create)
                } label: {
                    Image(systemSymbol: .plus)
                }
            }
        }
    }

    @ViewBuilder
    private func makeLatestItemsSection() -> some View {
        Section {
            HStack {
                if items.isEmpty {
                    Hint(
                        titleKey: "Dashboard.Section.Items.Empty.Hint",
                        systemName: "doc",
                        size: .large
                    )
                }
                else {
                    ScrollView(.horizontal) {
                        ForEach(items) { item in
                            ItemThumbnail(
                                item: item,
                                size: .large,
                                action: { path.append(item) }
                            )
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Dashboard.Section.LatestItems.Title")
                Spacer()
                NavigationLink {
                    ItemDetailView(initialState: .create)
                } label: {
                    Image(systemSymbol: .plus)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DashboardView()
}
