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
                makeLatestCartons()
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .navigationTitle("Fardal")
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
        Section("Your collections") {
            HStack {
                Button("") {}
                    .buttonStyle(LargeAddButton())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
        }
    }

    @ViewBuilder
    private func makeLatestCartons() -> some View {
        Section("Your latest items") {
            HStack {
                ScrollView(.horizontal) {
                    NavigationLink {
                        ItemDetailView(item: .empty, initialViewMode: .create)
                    } label: {
                        Text("New")
                    }

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
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
        }
    }
}

extension DashboardView {}

#Preview {
    DashboardView()
}
