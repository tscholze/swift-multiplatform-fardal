//
//  ItemCrudView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI
import PhotosUI

/// Represents a [View] that shows the detail of the model
/// and enables the user to perform CRUD operations on the [Item].
struct ItemDetailView: View {
    // MARK: - Properties -
    
    /// Underlying item that shall be target of CRUD operations
    let item: Item
    
    /// Initials view mode
    let initialViewModel: ViewMode
    
    // MARK: - Private properties -
    
    @State private var draft: ItemDraft
    @State private var viewMode: ViewMode = .edit
    @State private var showAddCustomAttributeSheet = false
    @State private var showIconWizard = false
    @State private var selectedColor: Color = Color.clear
    @State private var imagesData = [ImageData]()
    @State private var imageSelection: PhotosPickerItem? = nil
    @State private var iconData: Data? = nil
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
        Form {
            makeRequiredSection()
            makePhotosSection()
            makeTaggingSection()
            makeCustomAttributesSection()
            makeActionsSection()
        }
        .navigationBarBackButtonHidden(viewMode != .read)
        .toolbar { makeToolbar() }
        .onAppear(perform: onDidAppear)
        .alert("Item.Draft.Detail.Action.AddAttribute", isPresented: $showAddCustomAttributeSheet) {
            makeAddCustomAttributeAlertContent()
        }
    }
}

// MARK: - Life cyle -

extension ItemDetailView {
    private func onDidAppear() {
        viewMode = initialViewModel
        selectedColor = Color(hex: draft.hexColor)
        imagesData = draft.imagesData
    }
}

// MARK: - View builders -

extension ItemDetailView {
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
            Group {
                if imagesData.isEmpty {
                    HStack(alignment: .center) {
                        VStack {
                            Image(systemName: "rectangle.center.inset.filled.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                            
                            Text("Item.Draft.Detail.Section.Photo.Empty.Icon.Hint")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 150)
                        
                        Divider()
                        
                        VStack {
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                            
                            Text("Item.Draft.Detail.Section.Photo.Empty.Library.Hint")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 150)
                    }
                    .foregroundStyle(.secondary)
                    .opacity(0.6)
                    .frame(alignment: .center)
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            // List of images
                            ForEach(imagesData, id: \.id) { imageData in
                                Image(uiImage: imageData.uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .overlay(alignment: .topTrailing) {
                                        if viewMode != .read {
                                            Button {
                                                imagesData.removeAll(where: { $0.id == imageData.id })
                                            } label: {
                                                Image(systemName: "x.circle.fill")
                                                    .foregroundStyle(.white)
                                                    .opacity(0.6)
                                                    .shadow(radius: 2)
                                                    .padding(4)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .frame(height: 80)
        } header: {
            HStack {
                Text("Item.Draft.Detail.Section.Photos.Title \(draft.imagesData.count) / 3")
                if viewMode != .read {
                    HStack {
                        Button {
                            //
                        } label: {
                            PhotosPicker(
                                selection: $imageSelection,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "photo.badge.plus")
                            }
                        }
                        
                        Button {
                            showIconWizard.toggle()
                        } label: {
                            Image(systemName: "rectangle.center.inset.filled.badge.plus")
                        }

                    }
                }
            }
            .sheet(isPresented: $showIconWizard) {
              SymbolWizardView(selectedData: $iconData)
            }
        }
        .onChange(of: iconData) { n, o in
            onIconDataChanged(oldValue: n, newValue: o)
        }
        .onChange(of: imageSelection, onChangeImageSelection(oldValue:newValue:))
        .onChange(of: imagesData) { draft.imagesData = $1 }
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
    private func makeActionsSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            if let modelId = draft.existingId {
                HStack {
                    Spacer()
                    Button("Item.Draft.Detail.Actions.DeleteItem", role: .destructive) {
                        ItemDatabaseOperations.shared.delete(withId: modelId)
                        dismiss()
                    }
                }
            }
        }
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
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        if viewMode == .read {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewMode = .edit }) {
                    Text("Item.Draft.Action.Edit")
                }
            }
        } else {
            
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { onCancelTapped() }) {
                    Text("Item.Draft.Action.Cancel")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { onSaveButtonTapped() }) {
                    Text("Item.Draft.Action.Save")
                }
            }
        }
    }
}

// MARK: - Actions -

extension ItemDetailView {
    
    private func onChangeImageSelection(oldValue: PhotosPickerItem?, newValue: PhotosPickerItem?) {
        guard let newValue else { return }
        
        newValue.loadTransferable(type: Data.self) { result in
            switch result {
            case let .success(.some(data)):
                let newImage = ImageData(data: data)
                imagesData.append(newImage)
            default: print("Failed")
            }
        }
    }
    
    private func onIconDataChanged(oldValue: Data?, newValue: Data?) {
        guard let newValue else { return }
        imagesData.insert(.init(data: newValue), at: 0)
    }
    
    private func onCancelTapped() {
        draft = .from(item: item)
        selectedColor = Color(hex: draft.hexColor)
        imagesData = draft.imagesData
        viewMode = .read
    }
    
    private func onAddIconTapped() {
        showIconWizard.toggle()
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
        ItemDetailView(item: .mocked, initialViewMode: .read)
    }
}
