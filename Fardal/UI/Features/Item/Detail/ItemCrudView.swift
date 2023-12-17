//
//  ItemCrudView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI
import PhotosUI

/// Represents a [View] that enables the user to perform
/// CRUD operations on an [Item].
struct ItemCrudView: View {
    // MARK: - Properties -
    
    /// Underlying item that shall be target of CRUD operations
    let item: Item
    
    /// Initials view mode
    let initialViewModel: ViewMode
    
    // MARK: - Private properties -
    
    @State private var draft: ItemDraft
    @State private var viewMode: ViewMode = .edit
    @State private var showAddCustomAttributeSheet = false
    @State private var selectedColor: Color = Color.clear
    @State private var imageSelection: PhotosPickerItem? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: - Init -
    
    init(item: Item, initialViewMode: ViewMode) {
        self.initialViewModel = initialViewMode
        self.item = item
        self._draft = .init(initialValue: .from(item: item))
    }
    

    // MARK: - UI -
    
    var body: some View {
        VStack(spacing: 0) {
            
            makeToolbar()
            
            // User input
            Form {
                makeRequiredSection()
                makePhotosSection()
                makeTaggingSection()
                makeCustomAttributesSection()
            }
            
            // Actions
            makeActions()
        }
        .onAppear(perform: onDidAppear)
        .alert("Item.Draft.Detail.Action.AddAttribute", isPresented: $showAddCustomAttributeSheet) {
            makeAddCustomAttributeAlertContent()
        }
    }
}

// MARK: - Life cyle -

extension ItemCrudView {
    private func onDidAppear() {
        viewMode = initialViewModel
        selectedColor = Color(hex: draft.hexColor)
    }
}

// MARK: - View builders -

extension ItemCrudView {
    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("Item.Draft.Detail.Section.Required.Title") {
            // Name
            if viewMode == .read {
                Text(draft.title)
                Text(draft.summary)
            } else {
                TextField("Item.Draft.Detail.Section.Required.Name", text: $draft.title)
                
                // Summary
                TextField("Item.Draft.Detail.Section.Required.Summary", text: $draft.summary)
            }
        }
    }
    
    @ViewBuilder
    private func makeTaggingSection() -> some View {
        Section("Item.Draft.Detail.Section.Tagging.Title") {
            // Color
            HStack(alignment: .center) {
                Text("Item.Draft.Detail.Section.Tagging.Flag")
                
                // Identicator
                Image(systemName: "flag.fill")
                    .foregroundStyle(Color(hex: draft.hexColor))
                
                if viewMode != .read {
                    // Picker
                    ColorPicker("", selection: $selectedColor)
                        .onChange(of: selectedColor) { oldValue, newValue in
                            draft.hexColor = newValue.hexValue
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePhotosSection() -> some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    // List of images
                    ForEach(draft.imagesData, id: \.id) { imageData in
                        Image(uiImage: imageData.uiImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(alignment: .topTrailing) {
                                if viewMode != .read {
                                    Button {
                                        withAnimation {
                                            draft.imagesData.removeAll(where: { $0.id == imageData.id })
                                        }
                                    } label: {
                                        Image(systemName: "x.circle.fill")
                                            .foregroundStyle(.white)
                                            .shadow(radius: 2)
                                            .padding(4)
                                    }
                                }
                            }
                    }
                }
                .frame(height: 80)
            }
        } header: {
            HStack {
                Text("Item.Draft.Detail.Section.Photos.Title \(draft.imagesData.count) / 3")
                if viewMode != .read {
                    Button {
                        //
                    } label: {
                        PhotosPicker(
                            selection: $imageSelection,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
        .onChange(of: imageSelection) { _, newValue in
            if let newValue {
                newValue.loadTransferable(type: Data.self) { result in
                    switch result {
                    case let .success(.some(data)):
                        let newImage = ImageData(data: data)
                        withAnimation { draft.imagesData.append(newImage) }
                    default: print("Failed")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeCustomAttributesSection() -> some View {
        Section {
            List {
                ForEach(draft.customAttributes) { attribute in
                    ItemCustomAttributeTypes(rawValue: attribute.layout)?
                        .makeView(for: attribute, with: viewMode)
                }
                .onDelete(perform: onDeleteCustomTapped)
                .deleteDisabled(viewMode == .read)
            }
        } header: {
            HStack {
                Text("Item.Draft.Detail.Section.Attributes.Title")
                if viewMode != .read {
                    Button(
                        action: { onAddCustomTapped() },
                        label: {
                            Image(systemName: "plus.circle")
                        }
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeActions() -> some View {
        VStack {
            if let modelId = draft.existingId {
                Button("Item.Draft.Detail.Actions.DeleteItem", role: .destructive) {
                    ItemDatabaseOperations.shared.delete(withId: modelId)
                    dismiss()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
    
    @ViewBuilder
    private func makeAddCustomAttributeAlertContent() -> some View {
        // Date
        Button("Item.Draft.Detail.Action.AddDateAttribute") {
            onAddDateCustomAttributeTapped()
        }
        
        // Price
        Button("Item.Draft.Detail.Action.AddPriceAttribute") {
            onAddPriceCustomAttributeTapped()
        }
        
        // Url
        Button("Item.Draft.Detail.Action.AddUrlAttribute") {
            onAddUrlCustomAttributeTapped()
        }
        
        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }
    
    @ViewBuilder
    private func makeToolbar() -> some View {
        Group {
            if viewMode == .read {
                HStack(alignment: .center) {
                    // Back button
                    Button(action: { onBackTapped() }) {                      
                        Text("Item.Draft.Action.Back")
                    }
                    .buttonStyle(.bordered)
                    
                    // Stretch it
                    Spacer()
                    
                    // Edit button
                    Button(action: { viewMode = .edit }) {
                        Text("Item.Draft.Action.Edit")
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                HStack(alignment: .center) {
                    // Back button
                    Button(action: { onCancelTapped() }) {
                        Text("Item.Draft.Action.Cancel")
                    }
                    .buttonStyle(.bordered)
                    
                    // Stretch it
                    Spacer()
                    
                    // Save button
                    Button(action: { onSaveButtonTapped() }) {
                        Text("Item.Draft.Action.Save")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(uiColor: UIColor.systemGroupedBackground))
    }
}

// MARK: - Actions -

extension ItemCrudView {
    
    private func onBackTapped() {
        dismiss()
    }
    
    private func onCancelTapped() {
        draft = .from(item: item)
        viewMode = .read
    }
    
    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddPriceCustomAttributeTapped() {
        draft.customAttributes.append(.emptyPriceAttribute)
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddDateCustomAttributeTapped() {
        draft.customAttributes.append(.emptyDateAttribute)
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddUrlCustomAttributeTapped() {
        draft.customAttributes.append(.emptyUrlAttribute)
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onDeleteCustomTapped(withIndexSet indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let attributeToDelete = draft.customAttributes[index]
        draft.customAttributes.removeAll(where: { $0.id == attributeToDelete.id  })
        modelContext.delete(attributeToDelete)
    }
    
    private func onSaveButtonTapped() {
        item.title = draft.title
        item.summary = draft.summary
        item.customAttributes = draft.customAttributes
        item.hexColor = draft.hexColor
        item.imageDatas = draft.imagesData
        item.updatedAt = .now
        
        viewMode = .read
    }
    
    private func onEditButtonTapped() {
        viewMode = .edit
    }
}

// MARK: - Preview -

#Preview {
    NavigationView {
        ItemCrudView(item: .mocked, initialViewMode: .read)
    }
}
