//
//  DashboardView.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    // MARK: - Private properties -

    @Query(sort: \ItemModel.createdAt, order: .reverse)
    private var items: [ItemModel]

    @Query(sort: \ItemModel.createdAt, order: .reverse)
    private var collections: [ItemModel]

    // MARK: - UI -

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                makeCollectionsSection()
                makeLatestItemsSection()
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .navigationTitle("Dashboard.Title")
        }
        .tabItem {
            Label("Dashboard.Title", systemSymbol: .house)
        }
    }
}

// MARK: - View builders -

extension DashboardView {
    @ViewBuilder
    private func makeCollectionsSection() -> some View {
        Section {
            HStack {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(initialState: .read(item))
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 80)
        } header: {
            HStack {
                Text("Dashboard.Section.LatestCollections.Title")
                Spacer()
                NavigationLink {
                    ItemDetailView(initialState: .create)
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
                ScrollView(.horizontal) {
                    ForEach(items) { item in
                        NavigationLink {
                            ItemDetailView(initialState: .read(item))
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
        .frame(height: 60)
    }
}

#Preview {
    DashboardView()
}
