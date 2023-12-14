//
//  ContentView.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // MARK: - Properties -
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    // MARK: - UI -
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemCrudView(item: item, initialViewModel: .read)
                    } label: {
                        Text(item.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            modelContext.insert(Item.mocked)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
