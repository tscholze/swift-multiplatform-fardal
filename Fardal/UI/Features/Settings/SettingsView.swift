//
//  SettingsView.swift
//  Fardal
//
//  Created by Tobias Scholze on 15.12.23.
//

import SwiftUI
import SwiftData

/// Responsible for rendering the stack behind the
/// "Settings" tab bar item.
struct SettingsView: View {
    // MARK: - Properties -

    @AppStorage("appereance") private var currentAppereance: Appereance = .system
    @Query private var items: [Item]

    // MARK: - UI -

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    makeSectionAppereance()
                    makeSectionDataInformation()
                }
                makeFooterInformation()
            }
            .navigationTitle("Settings.Title")
        }
        .tabItem {
            Image(systemName: "gearshape")
            Text("Settings.Title")
        }
    }
}

// MARK: - View builder -

extension SettingsView {
    @ViewBuilder
    private func makeSectionAppereance() -> some View {
        Section {
            EmptyView()
        } header: {
            Text("Settings.Appereance.Title")
        } footer: {
            Picker("Settings.Appereance.Mode", selection: $currentAppereance) {
                Text("Settings.Appereance.Mode.System").tag(Appereance.system)
                Text("Settings.Appereance.Mode.Light").tag(Appereance.light)
                Text("Settings.Appereance.Mode.Dark").tag(Appereance.dark)
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private func makeSectionDataInformation() -> some View {
        Section("Settings.DataInformation") {
            LabeledContent("Settings.DataInformation.NumberOfItems", value: "\(items.count) / ∞")
        }
    }

    @ViewBuilder
    private func makeFooterInformation() -> some View {
        VStack {
            Divider()
                .opacity(0.5)
                .padding([.horizontal], 40)

            Text("Settings.Footer.Version")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
}

// MARK: - Preview -

#Preview {
    SettingsView()
}
