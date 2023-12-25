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
    // MARK: - System properties -

    @AppStorage("appereance") private var currentAppereance: Appereance = .system
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var items: [ItemModel]
    @Query private var collections: [CollectionModel]
    @Query private var images: [ImageDataModel]

    // MARK: - UI -

    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.none) {
                Form {
                    makeSectionAppereance()
                    makeSectionDataInformation()
                    makeActionSection()
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
            Text("Settings.Section.Appereance.Title")
        } footer: {
            Picker("Settings.Section.Appereance.Mode", selection: $currentAppereance) {
                Text("Settings.Section.Appereance.Mode.System").tag(Appereance.system)
                Text("Settings.Section.Appereance.Mode.Light").tag(Appereance.light)
                Text("Settings.Section.Appereance.Mode.Dark").tag(Appereance.dark)
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private func makeSectionDataInformation() -> some View {
        Section("Settings.Section.DataInformation") {
            LabeledContent("Settings.Section.DataInformation.NumberOfCollections", value: "\(collections.count) / ∞")
            LabeledContent("Settings.Section.DataInformation.NumberOfItems", value: "\(items.count) / ∞")
            LabeledContent("Settings.Section.DataInformation.NumberOfImages", value: "\(images.count) / ∞")
        }
    }

    @ViewBuilder
    private func makeActionSection() -> some View {
        Section("Settings.Section.Actions") {
            Button("Settings.Section.Actions.InsertMockCollections") {
                Task {
                    await CollectionModel.makeMockedCollections()
                        .forEach { modelContext.insert($0) }
                }
            }

            Button("Settings.Section.Actions.ClearAll") {
                do {
                    try modelContext.delete(model: CollectionModel.self)
                    try modelContext.delete(model: ItemModel.self)
                    try modelContext.delete(model: ItemCustomAttribute.self)
                    try modelContext.delete(model: ImageDataModel.self)
                }
                catch {
                    print("Failed to clear all data")
                }
            }
        }
    }

    @ViewBuilder
    private func makeFooterInformation() -> some View {
        VStack {
            Divider()
                .padding([.horizontal], 40)

            Text("Settings.Footer.Version")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .opacity(0.5)
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
}

// MARK: - Preview -

#Preview {
    SettingsView()
}
