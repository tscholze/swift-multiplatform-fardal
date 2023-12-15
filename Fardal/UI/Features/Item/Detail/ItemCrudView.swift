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
    
    @State private var name = ""
    @State private var summary = ""
    @State private var viewMode: ViewMode = .edit
    @State private var selectedColor: Color = .clear
    @State private var showAddCustomAttributeSheet = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var imageSelection: PhotosPickerItem? = nil
    @State var coverImage: Image?
    
    // MARK: - UI -
    
    var body: some View {
        VStack(spacing: 0) {
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
        .navigationTitle(item.title.isEmpty == true ? "New item" : item.title)
        .toolbar { makeToolbar() }
        .onAppear(perform: onDidAppear)
        .alert("Item.Detail.Action.AddAttribute", isPresented: $showAddCustomAttributeSheet) {
            makeAddCustomAttributeAlertContent()
        }
    }
}

// MARK: - Life cyle -

extension ItemCrudView {
    private func onDidAppear() {
        viewMode = initialViewModel
        name = item.title
        summary = item.summary
        selectedColor = Color(hex: item.hexColor)
    }
}

// MARK: - View builders -

extension ItemCrudView {
    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("Item.Detail.Section.Required.Title") {
            // Name
            if viewMode == .read {
                Text($name.wrappedValue)
                Text($summary.wrappedValue)
            } else {
                TextField("Item.Detail.Section.Required.Name", text: $name)
                    .onChange(of: name) { oldValue, newValue in
                        item.title = name
                    }
                
                // Summary
                TextField("Item.Detail.Section.Required.Summary", text: $summary)
            }
        }
    }
    
    @ViewBuilder
    private func makeTaggingSection() -> some View {
        Section("Item.Detail.Section.Tagging.Title") {
            // Color
            HStack(alignment: .center) {
                // Title
                Text("Item.Detail.Section.Tagging.Flag")
                
                // Identicator
                Image(systemName: "flag.fill")
                    .foregroundStyle(Color(hex: item.hexColor))
                
                // Picker
                if viewMode != .read {
                    ColorPicker("", selection: $selectedColor)
                        .onChange(of: selectedColor) { oldValue, newValue in
                            item.hexColor = newValue.hexValue
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePhotosSection() -> some View {
        Section {
            HStack {
                if let coverImage {
                    coverImage
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                //
                            } label: {
                                Image(systemName: "x.circle.fill")
                                    .foregroundStyle(.white)
                                    .shadow(radius: 2)
                                    .padding(4)
                            }

                        }
                }
            }
        } header: {
            HStack {
                Text("Item.Detail.Section.Photos.Title")
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
                .onChange(of: imageSelection) { oldValue, newValue in
                    if let imageSelection {
                        imageSelection.loadTransferable(type: TransformableImage.self) { result in
                            switch result {
                            case .success(.some(let transformableImage)): coverImage = transformableImage.image
                            default: print("Failed")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeCustomAttributesSection() -> some View {
        Section {
            List {
                ForEach(item.customAttributes) { attribute in
                    ItemCustomAttributeTypes(rawValue: attribute.layout)?
                        .makeView(for: attribute, with: viewMode)
                }
                .onDelete(perform: onDeleteCustomTapped)
                .deleteDisabled(viewMode == .read)
            }
        } header: {
            HStack {
                Text("Item.Detail.Section.Attributes.Title")
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
            if initialViewModel != .create {
                Button("Item.Detail.Actions.DeleteItem", role: .destructive) {
                    modelContext.delete(item)
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
        Button("Item.Detail.Action.AddDateAttribute") {
            onAddDateCustomAttributeTapped()
        }
        
        // Price
        Button("Item.Detail.Action.AddPriceAttribute") {
            onAddPriceCustomAttributeTapped()
        }
        
        // Url
        Button("Item.Detail.Action.AddUrlAttribute") {
            onAddUrlCustomAttributeTapped()
        }
        
        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        // Save
        if viewMode != .read {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { onSaveButtonTapped() }) {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
        
        // Edit
        if viewMode == .read {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { onEditButtonTapped() }) {
                    Image(systemName: "pencil.circle")
                }
            }
        }
    }
    
    private func makeSymbolImage() -> some View {
        Text("FOO")
    }
}

// MARK: - Actions -

extension ItemCrudView {
    
    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddPriceCustomAttributeTapped() {
        item.customAttributes.append(.emptyPriceAttribute)
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddDateCustomAttributeTapped() {
        item.customAttributes.append(.emptyDateAttribute)
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddUrlCustomAttributeTapped() {
        item.customAttributes.append(.emptyUrlAttribute)
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onDeleteCustomTapped(withIndexSet indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let attributeToDelete = item.customAttributes[index]
        item.customAttributes.removeAll(where: { $0.id == attributeToDelete.id  })
        modelContext.delete(attributeToDelete)
    }
    
    private func onSaveButtonTapped() {
        viewMode = .read
    }
    
    private func onEditButtonTapped() {
        viewMode = .edit
    }
}

// MARK: - Preview -

#Preview {
    NavigationView {
        ItemCrudView(
            item: .mocked,
            initialViewModel: .create
        )
    }
}
