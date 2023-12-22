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
    @Query private var items: [ItemModel]

    // MARK: - UI -

    var body: some View {
        TabView {
            DashboardView()
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ItemModel.self, inMemory: true)
}
