//
//  ItemCrudView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI

struct ItemCrudView: View {
    // MARK: - Properties -
    
    let item: Item
    let mode: Mode
    
    // MARK: - Private properties -
    
    @State private var selectedColor: Color = .clear
    @State private var name = ""
    @State private var summary = ""
    @State private var showAddCustomAttributeSheet = false
    
    // MARK: - UI -
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                // Section: Required
                Section("Required") {
                    // Name
                    TextField("Name", text: $name)
                        .onChange(of: name) { oldValue, newValue in
                            item.title = name
                        }
                    
                    // Summary
                    TextField("Summary", text: $summary)
                }
                
                // Section: Tagging
                Section("Tagging") {
                    // Color
                    HStack {
                        // Identicator
                        Circle()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color(hex: item.hexColor))
                        
                        // Picker
                        ColorPicker("Flag", selection: $selectedColor)
                            .onChange(of: selectedColor) { oldValue, newValue in
                                item.hexColor = newValue.hexValue
                            }
                    }
                }
                
                // Section: Custom
                Section {
                    VStack {
                        ForEach(item.customAttributes) { attribute in
                            switch attribute.identifier {
                            case "price": PriceCustomAttributeView(
                                mode: .read,
                                store: .init(payload: attribute.payload))
                                
                                
                            default: Text("Unsupported attribute: \(attribute.identifier)")
                            }
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
                if mode == .update {
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
                ToolbarItem(placement: .primaryAction) {
                    Image(systemName: "checkmark.circle")
                }
            }
            .onAppear {
                name = item.title
                summary = item.summary
                selectedColor = Color(hex: item.hexColor)
            }
            .sheet(isPresented: $showAddCustomAttributeSheet) {
                VStack {
                    Button("Add price information") {
                        item.customAttributes.append(
                            .init(
                                identifier: "price",
                                payload: [
                                    "currencyCode": "EUR",
                                    "price": "0.00"
                                ]
                            )
                        )
                        
                        showAddCustomAttributeSheet.toggle()
                    }
                }
                .presentationDetents([.height(200)])
            }
        }
    }
    
    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }
}

extension ItemCrudView {
    enum Mode {
        case create
        case update
    }
}

// MARK: - Preview -

#Preview {
    NavigationView {
        ItemCrudView(
            item: .mocked,
            mode: .create
        )
    }
}


protocol ItemAttribute {
    var type: ItemAttributeType { get set }
    var payload: [String:String] {get set }
}

enum ItemAttributeType {
    case currency
}

class CurrencyItemAttribute: ItemAttribute {
    var type: ItemAttributeType = ItemAttributeType.currency
    var payload: [String : String] = [:]
}
