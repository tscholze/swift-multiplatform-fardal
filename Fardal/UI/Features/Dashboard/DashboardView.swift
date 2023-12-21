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

    @Query(sort: \Item.createdAt, order: .reverse)
    private var items: [Item]

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
                Button("") {}
                    .buttonStyle(LargeAddButton())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
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
                        ZStack(alignment: .center) {
                            if let uiImage = item.imageDatas.first?.uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            }
                            else {
                                Image(systemSymbol: .questionmark)
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
