//
//  PriceCustomAttributeView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI

struct PriceCustomAttributeView: View {
    
    // MARK: - Properties -
    
    /// View mode for the view
    let mode: ViewMode
    
    /// Data store whichs information shall be rendered
    let store: PriceCustomAttributeStore
    
    // MARK: - States -
    
    @State private var title: String = ""
    @State private var price: Decimal = 0
    @State private var currencyCode = "EUR"
    
    // MARK: - UI -
    
    var body: some View {
        if mode == .read {
            VStack(alignment: .leading) {
                Text(store.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(store.price, format: .currency(code: store.currencyCode))
            }
        } else {
            VStack(spacing: 0) {
                // Title
                TextField("Title", text: $title)
                    .font(.caption)
                    .onChange(
                        of: title,
                        onTitleChanged(oldValue:newValue:)
                    )
        
                // Price and Currency chooser
                HStack {
                    // Value
                    TextField("Price", value: $price, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                        .onChange(
                            of: price,
                            onPriceChanged(oldValue:newValue:)
                        )
                    
                    Spacer()
                    
                    Picker("", selection: $currencyCode) {
                        Text("Euro").tag("EUR")
                        Text("Dollar").tag("USD")
                    }
                    .onChange(
                        of: currencyCode,
                        onCurrencyCodeChanged(oldValue:newValue:)
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers -
    private func onTitleChanged(oldValue: String, newValue: String) {
        store.title = newValue
    }
    
    private func onCurrencyCodeChanged(oldValue: String, newValue: String) {
        store.currencyCode = newValue
    }
    
    private func onPriceChanged(oldValue: Decimal, newValue: Decimal) {
        // Validate
        // if valide -> store it
        store.price = newValue
    }
}

// MARK: - Store -

class PriceCustomAttributeStore {
    
    // MARK: - Properties -
    
    /// Raw data source of the attribute
    private(set) var attribute: ItemCustomAttribute
    
    /// Title of the price attribute.
    /// E.g. "price" or "UVP".
    var title: String {
        didSet { attribute.payload["title"] = title }
    }
    
    /// Currency code of the price
    /// E.g.: "USD", "EUR"
    var currencyCode: String {
        didSet { attribute.payload["currencyCode"] = currencyCode }
    }
    
    /// Price value in decimal format.
    var price: Decimal {
        didSet { attribute.payload["price"] = "\(price)" }
    }
    
    // MARK: - Init -
    
    init(attribute: ItemCustomAttribute) {
        
        // Validate payload
        guard let title =  attribute.payload["title"],
              let code = attribute.payload["currencyCode"],
              let rawPrice = attribute.payload["price"],
              let doublePrice = Double(rawPrice)
        else {
            fatalError("Invalid payload")
        }
        
        // Set properties
        self.attribute = attribute
        self.title = title
        self.currencyCode = code
        self.price =  Decimal(doublePrice)
    }
}

// MARK: - Preview -

#Preview {
    PriceCustomAttributeView(
        mode: .edit,
        store: .init(attribute: ItemCustomAttribute.emptyPriceAttribute)
    )
}
