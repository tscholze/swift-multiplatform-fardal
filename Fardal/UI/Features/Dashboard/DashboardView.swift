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

    // TODO: Re-check if enum checks are working again in an upcoming Xcode version, source == .photo
    @Query(sort: \ImageModel.createdAt, order: .reverse)
    private var imagesData: [ImageModel]

    // MARK: - States -

    @State var path = NavigationPath()

    // MARK: - UI -

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                makeCollectionsSection()
                makeLatestItemsSection()
                makeItemListSection()
                makeAllImages()
            }
            .navigationTitle("Dashboard.Title")
            .navigationDestination(for: CollectionModel.self) { collection in
                CollectionDetailView(initialState: .read(collection))
            }
            .navigationDestination(for: ItemModel.self) { item in
                ItemDetailView(initialState: .read(item))
            }
            .navigationDestination(for: ImageModel.self) { imageData in
                ImageDetailView(initialState: .read(imageData))
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
                    ForEach(collections.prefix(10)) { collection in
                        CollectionThumbnail(
                            collection: collection,
                            size: .large,
                            action: { path.append(collection) }
                        )
                        .buttonStyle(.borderless)
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
                        LazyHStack {
                            ForEach(items.prefix(10)) { item in
                                ItemThumbnail(
                                    item: item,
                                    size: .large,
                                    action: { path.append(item) }
                                )
                                .buttonStyle(.borderless)
                            }
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

    @ViewBuilder
    private func makeItemListSection() -> some View {
        Section("Dashboard.Section.AllItems.Title") {
            if items.isEmpty {
                Text("Dashboard.Section.AllItems.Empty.Hint")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            else {
                List {
                    ForEach(items) { item in
                        ItemNavigationLink(item: item)
                            .buttonStyle(.borderless)
                    }
                }.frame(alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func makeAllImages() -> some View {
        Section("Dashboard.Section.AllImages.Title") {
            if imagesData.filter({ $0.source == .photo }).isEmpty {
                Text("Dashboard.Section.AllImages.Empty.Hint")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            else {
                LazyVGrid(columns: [.init(), .init(), .init()]) {
                    ForEach(imagesData.filter { $0.source == .photo }) { imageData in
                        Button(action: { print(path.count); path.append(imageData) }) {
                            imageData.image
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
    }

    private func onImageTapped(_: ImageModel) {
        print(path)
    }
}

#Preview {
    DashboardView()
}
