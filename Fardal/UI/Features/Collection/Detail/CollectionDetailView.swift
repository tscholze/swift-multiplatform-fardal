//
//  CollectionDetailView.swift
//  Fardal
//
//  Created by Tobias Scholze on 22.12.23.
//

import SwiftUI

struct CollectionDetailView: View {
    // MARK: - Private properties -

    private let collection: CollectionModel?
    private let intialViewMode: ViewMode

    // MARK: - States -

    @State private var isValid = true
    @State private var viewMode: ViewMode = .read
    @State private var title = ""
    @State private var summary = ""
    @State private var items = [ItemModel]()
    @State private var coverData = Data()
    @State private var showLinkItemSheet = false
    @State private var showAddItemAlert = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init -

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the viewMode and the datasource.
    init(initialState: CollectionDetailViewInitalState) {
        switch initialState {
        case let .read(collection):
            self.collection = collection
            intialViewMode = .read

        case .create:
            collection = nil
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
            makeItemsSection()
            makeActionsSection()
        }
        .onAppear(perform: onViewAppear)
        .toolbar { makeToolbar() }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Add Item", isPresented: $showAddItemAlert, actions: makeAddItemAlertContent)
        .sheet(isPresented: $showLinkItemSheet) {
            CollectionDetailLinkItemView(selectedItems: $items)
        }
    }
}

// MARK: - Actions -

extension CollectionDetailView {
    private func onViewAppear() {
        viewMode = intialViewMode
        title = collection?.title ?? ""
        summary = collection?.summary ?? ""
        items = collection?.items ?? []

        // Use existing cover image data or create a randomized one.
        if let data = collection?.coverImageData.data {
            coverData = data
        }
        else {
            Task {
                await updateCoverData()
            }
        }
    }

    private func onTitleChanged(oldValue _: String, newValue _: String) {
        Task {
            await updateCoverData()
            isValid = validateUserInput()
        }
    }

    private func onSummaryChanged(oldValue _: String, newValue _: String) {
        isValid = validateUserInput()
    }

    private func onEditButtonTapped() {
        viewMode = .edit
    }

    private func onCancelTapped() {
        if let collection {
            title = collection.title
            summary = collection.summary
            items = collection.items
        }
        else {
            dismiss()
        }
    }

    private func onSaveButtonTapped() {
        // If it is an update ...
        if let collection {
            collection.title = title
            collection.summary = summary
            collection.items = items
            collection.coverImageData.data = coverData
            viewMode = .read
        }

        // if it is a creation ...
        else {
            let newCollection = CollectionModel(
                coverImageData: .init(data: coverData),
                title: title,
                summary: summary,
                items: items
            )

            modelContext.insert(newCollection)
            dismiss()
        }
    }

    private func onLinkItemTapped() {
        showLinkItemSheet.toggle()
    }

    private func onAddItemTapped() {}

    private func updateCoverData() async {
        let content = InitialAvatarView(name: title.isEmpty ? "?" : title, dimension: 256)
        coverData = await ImageGenerator.fromContentToData(content: content)
    }
}

// MARK: - Validations -

extension CollectionDetailView {
    func validateUserInput() -> Bool {
        if title.isEmpty || summary.isEmpty {
            return false
        }

        return true
    }
}

// MARK: - View builders -

extension CollectionDetailView {
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        if viewMode == .read {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewMode = .edit }) {
                    Text("Item.Draft.Action.Edit")
                }
            }
        }
        else {
            // Cancel button
            if viewMode != .create {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { onCancelTapped() }) {
                        Text("Item.Draft.Action.Cancel")
                    }
                }
            }

            // Save button
            ToolbarItem(placement: .primaryAction) {
                Button(
                    "Item.Draft.Action.Save",
                    action: onSaveButtonTapped
                )
                .disabled(isValid == false)
            }
        }
    }

    @ViewBuilder
    private func makeAddItemAlertContent() -> some View {
        // Photo picker
        Button("CollectionDetail.Actions.LinkItem") {
            showLinkItemSheet.toggle()
        }

        // Camera
        Button("CollectionDetail.Actions.AddItem") {}

        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }

    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("CollectionDetail.Section.Required.Title") {
            // Mode: Read
            if viewMode == .read {
                HStack(alignment: .center) {
                    if let uiImage = UIImage(data: coverData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .frame(width: 80, height: 80)
                    }

                    VStack {
                        Text(title)
                        Text(summary)
                    }
                }
            }
            // Mode: Editable
            else {
                HStack(spacing: 12) {
                    if let uiImage = UIImage(data: coverData) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .frame(width: 60, height: 60)

                            Button("Re-Generate") {
                                Task { await updateCoverData() }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption2)
                        }
                    }

                    VStack {
                        TextField("CollectionDetail.Section.Required.Name", text: $title)
                            .onChange(of: title, onTitleChanged(oldValue:newValue:))

                        Divider()

                        // Summary
                        TextField("CollectionDetail.Section.Required.Summary", text: $summary)
                            .onChange(of: summary, onSummaryChanged(oldValue:newValue:))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeItemsSection() -> some View {
        Section {
            // Mode: Empty items
            if items.isEmpty == true {
                VStack(spacing: 12) {
                    Image(systemName: "doc")
                        .resizable()
                        .scaledToFit()

                    Text("CollectionDetail.Section.Items.Empty.Hint")
                        .font(.caption2)
                }
                .padding(8)
                .foregroundStyle(.secondary.opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 80)
            }
            else {
                // Mode: Filled items
                LazyVStack {
                    ForEach(items) { item in
                        NavigationLink {
                            ItemDetailView(initialState: .read(item))
                        } label: {
                            HStack {
                                if let uiImage = item.imagesData.first?.uiImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                }

                                Text(item.title)
                            }
                        }
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
            if let collection {
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
