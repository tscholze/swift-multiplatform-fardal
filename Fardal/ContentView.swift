//
//  ContentView.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
//

import SwiftUI
import SwiftData

/// Root content view
/// Allows the user to navigate the app and provides
/// a tab view.
struct ContentView: View {
    // MARK: - UI -

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard.Title", systemSymbol: .house) }

            SettingsView()
                .tabItem {
                    Label("Settings.Title", systemSymbol: .gearshape)
                }
        }
    }
}

// MARK: - Preview -

#Preview {
    ContentView()
        .modelContainer(
            for: ItemModel.self,
            inMemory: true
        )
}
