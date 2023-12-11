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
    
    @State private var viewMode: ViewMode = .edit
    @State private var selectedColor: Color = .clear
    @State private var name = ""
    @State private var summary = ""
    @State private var showAddCustomAttributeSheet = false
    
    // MARK: - UI -
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                // Section: Required
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
                
                // Section: Tagging
                Section("Tagging") {
                    // Color
                    HStack {
                        Text("Flag")
                        
                        // Identicator
                        Circle()
                            .frame(width: 16, height: 16)
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
                
                // Section: Custom
                Section {
                    List {
                        ForEach(item.customAttributes) { attribute in
                            switch attribute.layout {
                                // Price
                            case "price": 
                                PriceCustomAttributeView(
                                    mode: viewMode,
                                    store: .init(attribute: attribute)
                                )
                                
                                // Fallback
                            default: Text("Unsupported layout: \(attribute.layout)")
                            }
                        }
                        .onDelete{ indexSet in
                            print(indexSet)
                        }
                    }
                        
                } header: {
                    HStack {
                        Text("Custom")
                        Button(
                            action: { onAddCustomTapped() },
                            label: {
                                Image(systemName: "plus.circle")
                            }
                        )
                    }
                }
            }
            
            // Actions
            VStack {
                if initialViewModel != .create {
                    Button("Delete item", role: .destructive) {
                        print("Delete")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationTitle(item.title.isEmpty == true ? "New item" : item.title)
            .toolbar {
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
            .onAppear {
                name = item.title
                summary = item.summary
                selectedColor = Color(hex: item.hexColor)
            }
            .alert("Add attribute", isPresented: $showAddCustomAttributeSheet) {
                Button("Add price information") {
                   onAddPriceCustomAttributeTapped()
                }
            }
        }
    }
    
    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onAddPriceCustomAttributeTapped() {
        item.customAttributes.append(
            .emptyPriceAttribute
        )
        
        showAddCustomAttributeSheet.toggle()
    }
    
    private func onDeleteCustomTapped(withIndexSet indexSet: IndexSet) {
        print(indexSet)
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
        .modelContainer(for: Item.self, inMemory: true)
    }
}
