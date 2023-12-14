//
//  ItemCrudView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI

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
        .alert("Add attribute", isPresented: $showAddCustomAttributeSheet) {
            makeAddCustomAttributeAlertContent()
        }
    }
}

// MARK: - Life cyle -

extension ItemCrudView {
    private func onDidAppear() {
        name = item.title
        summary = item.summary
        selectedColor = Color(hex: item.hexColor)
    }
}

// MARK: - View builders -

extension ItemCrudView {
    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("Required") {
            // Name
            if viewMode == .read {
                Text($name.wrappedValue)
                Text($summary.wrappedValue)
            } else {
                TextField("Name", text: $name)
                    .onChange(of: name) { oldValue, newValue in
                        item.title = name
                    }
                
                // Summary
                TextField("Summary", text: $summary)
            }
        }
    }
    
    @ViewBuilder
    private func makeTaggingSection() -> some View {
        Section("Tagging") {
            // Color
            HStack(alignment: .center) {
                Text("Flag")
                
                // Identicator
                Image(systemName: "flag.fill")
                    .foregroundStyle(Color(hex: item.hexColor))
                
                if viewMode != .read {
                    // Picker
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
        Section("Photo") {
            
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
                Text("Custom")
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
                Button("Delete item", role: .destructive) {
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
        Button("Add date information") {
            onAddDateCustomAttributeTapped()
        }
        
        // Price
        Button("Add price information") {
            onAddPriceCustomAttributeTapped()
        }
        
        // Cancel
        Button("Cancel", role: .cancel) {
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
