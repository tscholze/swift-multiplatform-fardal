//
//  CollectionDetailView.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import SwiftUI

/// Represents a [View] that shows the detail of the model
/// and enables the user to perform CRUD operations on a [Collection].
struct CollectionDetailView: View {
    // MARK: - Private properties -

    @Bindable private var collection: CollectionModel
    private let intialViewMode: ViewMode

    // MARK: - System properties -

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - States -

    @State private var isValid = true
    @State private var viewMode: ViewMode = .read
    @State private var items = [ItemModel]()
    @State private var coverData = Data()
    @State private var showLinkItemSheet = false
    @State private var showAddItemSheet = false
    @State private var showAddItemAlert = false

    // MARK: - Init -

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the view mode and the datasource.
    init(initialState: ViewInitalState<CollectionModel>) {
        switch initialState {
        case let .read(collection):
            self.collection = collection
            intialViewMode = .read

        case .create:
            collection = .init(title: "", summary: "")
            intialViewMode = .create

        case let .edit(collection):
            self.collection = collection
            intialViewMode = .edit
        }
    }

    // MARK: - UI -

    var body: some View {
        Form {
            makeRequiredSection()
            makeCustomIdSection()
            makeItemsSection()
            makeActionsSection()
        }
        .onAppear(perform: onViewAppear)
        .toolbar(content: makeToolbar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewMode == .edit)
        .alert("CollectionDetail.Actions.AddItem", isPresented: $showAddItemAlert) { makeAddItemAlertContent()
        }
        .sheet(isPresented: $showLinkItemSheet) {
            CollectionDetailLinkItemView(selectedItems: $items)
        }
        .sheet(isPresented: $showAddItemSheet) {
            ItemDetailView(initialState: .create)
        }
    }
}

// MARK: - Actions -

extension CollectionDetailView {
    private func onViewAppear() {
        viewMode = intialViewMode
    }

    private func onTitleChanged(oldValue _: String, newValue _: String) {
        Task {
            await updateCoverData()
            updateInputValidity()
        }
    }

    private func onSummaryChanged(oldValue _: String, newValue _: String) {
        updateInputValidity()
    }

    private func onEditButtonTapped() {
        viewMode = .edit
    }

    private func onCancelTapped() {
        switch viewMode {
        case .create: dismiss()
        case .read: dismiss()
        case .edit:
            while modelContext.undoManager?.canUndo == true {
                modelContext.undoManager?.undo()
            }
            viewMode = .read
        }
    }

    private func onSaveButtonTapped() {
        switch viewMode {
        case .create:
            modelContext.insert(collection)
            dismiss()
        case .edit:
            try? modelContext.save()
            viewMode = .read

        default:
            fatalError("Unsupported operation for view mode: '\(viewMode)'")
        }
    }

    private func onLinkItemTapped() {
        showLinkItemSheet.toggle()
    }

    private func updateCoverData() async {
        let name = collection.title.isEmpty ? "?" : collection.title
        let content = InitialAvatarView(name: name, dimension: 256)
        let data = await ImageGenerator.fromContentToData(content: content)
        collection.coverImageData = data
    }
}

// MARK: - Validations -

extension CollectionDetailView {
    func updateInputValidity() {
        isValid = if collection.title.isEmpty || collection.summary.isEmpty {
            false
        }
        else {
            true
        }
    }
}

// MARK: - View builders -

extension CollectionDetailView {
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        if viewMode == .read {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewMode = .edit }) {
                    Text("ItemDetail.Action.Edit")
                }
            }
        }
        else {
            // Cancel button
            if viewMode != .create {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { onCancelTapped() }) {
                        Text("ItemDetail.Action.Cancel")
                    }
                }
            }

            // Save button
            ToolbarItem(placement: .primaryAction) {
                Button(
                    "ItemDetail.Action.Save",
                    action: onSaveButtonTapped
                )
                .disabled(isValid == false)
            }
        }
    }

    @ViewBuilder
    private func makeAddItemAlertContent() -> some View {
        // Link
        Button("CollectionDetail.Actions.LinkItem") {
            showLinkItemSheet.toggle()
        }

        // Add Item
        Button("CollectionDetail.Actions.AddItem") {}

        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }

    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("CollectionDetail.Section.Required.Title") {
            VStack(alignment: .leading) {
                // Mode: Read
                if viewMode == .read {
                    HStack(alignment: .center, spacing: Theme.Spacing.medium) {
                        if let uiImage = UIImage(data: coverData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .clipShape(Theme.Shape.roundedRectangle2)
                                .frame(width: 80, height: 80)
                        }

                        VStack(alignment: .leading) {
                            Text(collection.title)
                            Divider()
                            Text(collection.summary)
                        }
                    }
                }
                // Mode: Editable
                else {
                    HStack(spacing: Theme.Spacing.medium) {
                        if let uiImage = UIImage(data: coverData) {
                            VStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .clipShape(Theme.Shape.roundedRectangle2)
                                    .frame(width: 60, height: 60)

                                Button("Misc.Randomized") {
                                    Task { await updateCoverData() }
                                }
                                .buttonStyle(.bordered)
                                .font(.caption2)
                            }
                        }

                        VStack(alignment: .leading) {
                            TextField(
                                "CollectionDetail.Section.Required.Name",
                                text: $collection.title
                            )
                            .onChange(of: collection.title, onTitleChanged(oldValue:newValue:))

                            Divider()

                            // Summary
                            TextField(
                                "CollectionDetail.Section.Required.Summary",
                                text: $collection.summary
                            )
                            .onChange(of: collection.summary, onSummaryChanged(oldValue:newValue:))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeCustomIdSection() -> some View {
        Section {
            VStack(alignment: .leading) {
                if viewMode == .read {
                    if collection.customId.isEmpty {
                        Text("Misc.NotSet")
                    }
                    else {
                        Text(collection.customId)
                    }
                }
                else {
                    TextField(
                        "CollectionDetail.Section.CustomId.Text",
                        text: $collection.customId
                    )
                }
            }
        } header: {
            Text("CollectionDetail.Section.CustomId")
        } footer: {
            Text("CollectionDetail.Section.CustomId.Hint")
        }
    }

    @ViewBuilder
    private func makeItemsSection() -> some View {
        Section {
            // Mode: Empty items
            if items.isEmpty == true {
                Hint(
                    titleKey: "CollectionDetail.Section.Items.Empty.Hint",
                    systemName: "doc"
                )
            }
            else {
                // Mode: Filled items
                List {
                    ForEach(items) { item in
                        ItemNavigationLink(item: item)
                    }
                }
            }
        } header: {
            HStack {
                Text("CollectionDetail.Section.Items.Title")
                Spacer()

                // Add item button
                if viewMode != .read {
                    Button(action: { showAddItemAlert.toggle() }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeActionsSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            if viewMode != .create {
                HStack {
                    Spacer()
                    Button("CollectionDetail.Actions.DeleteCollection", role: .destructive) {
                        modelContext.delete(collection)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    CollectionDetailView(initialState: .create)
}
