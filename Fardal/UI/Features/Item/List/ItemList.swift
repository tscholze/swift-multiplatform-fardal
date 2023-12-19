//
//  ItemList.swift
//  Fardal
//
//  Created by Tobias Scholze on 14.12.23.
//

import SwiftUI
import SwiftData

/// Renders a list of stored items
/// in context of a tab item "list".
struct ItemListView: View {
    // MARK: - Properties -

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    // MARK: - UI -

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item, initialViewMode: .read)
                    } label: {
                        Text(item.title)
                    }
                }
                .onDelete(perform: onDeleteItems)
            }
            .navigationTitle("Item.List.Title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: onAddItemTapped) {
                        Label("Item.List.Action.Add", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Item.List.Detail.Empty")
        }
        .tabItem {
            Image(systemName: "list.bullet.rectangle")
            Text("Item.List.Title")
        }
        .navigationSplitViewStyle(.automatic)
    }
}

// MARK: - Actions -

extension ItemListView {
    private func onAddItemTapped() {
        withAnimation {
            modelContext.insert(Item.mocked)
        }
    }

    private func onDeleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    ItemListView()
        .modelContainer(for: Item.self, inMemory: true)
}
