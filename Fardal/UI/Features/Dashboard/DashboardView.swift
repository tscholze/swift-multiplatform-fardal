//
//  DashboardView.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import SwiftData

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
                    VStack(spacing: 12) {
                        Image(systemName: "doc.on.doc")
                            .resizable()
                            .scaledToFit()

                        Text("Dashboard.Section.Collections.Empty.Hint")
                            .font(.caption2)
                    }
                    .padding(8)
                    .foregroundStyle(.secondary.opacity(0.6))
                    .frame(maxWidth: .infinity)
                }
                else {
                    ForEach(collections) { collection in
                        Button {
                            path.append(collection)
                        } label: {
                            collection.coverImageData.image
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .frame(width: 80, height: 80)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 80)
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
                    VStack(spacing: 12) {
                        Image(systemName: "doc")
                            .resizable()
                            .scaledToFit()

                        Text("Dashboard.Section.Items.Empty.Hint")
                            .font(.caption2)
                    }
                    .padding(8)
                    .foregroundStyle(.secondary.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                }
                else {
                    ScrollView(.horizontal) {
                        ForEach(items) { item in
                            Button {
                                path.append(item)
                            } label: {
                                if let imageData = item.imagesData.first {
                                    imageData.image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                }
                                else {
                                    InitialAvatarView(name: item.title, dimension: 80)
                                }
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
}

#Preview {
    DashboardView()
}
