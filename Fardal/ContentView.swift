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
        TabView {
            ItemListView()
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
