//
//  PriceCustomAttributeView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI

struct PriceCustomAttributeView: View {
    
    // MARK: - Properties -
    
    let mode: ViewMode
    let store: PriceCustomAttributeStore
    
    // MARK: - States -
    
    @State private var price: Decimal = 0
    @State private var currencyCode = "EUR"
    
    // MARK: - UI -
    
    var body: some View {
        if mode == .read {
            Text(store.price, format: .currency(code: store.currencyCode))
        } else {
            HStack {
                // Currency
                Picker("Currency", selection: $currencyCode) {
                    Text("Euro").tag("EUR")
                    Text("Dollar").tag("USD")
                }
                .onChange(of: currencyCode, onCurrencyCodeChanged(oldValue:newValue:))
                
                // Value
                TextField("Price", value: $price, format: .currency(code: currencyCode))
                    .keyboardType(.decimalPad)
                    .onChange(of: price, onPriceChanged(oldValue:newValue:))
                
                // Spacer
                Spacer()
                
                Button(action: { onDeleteButtonTapped() }) {
                    Image(systemName: "minus.circle")
                }
            }
        }
    }
    
    // MARK: - Helpers -
    
    private func onCurrencyCodeChanged(oldValue: String, newValue: String) {
        store.currencyCode = newValue
    }
    
    private func onPriceChanged(oldValue: Decimal, newValue: Decimal) {
        // Validate
        // if valide -> store it
        store.price = newValue
    }
    
    private func onDeleteButtonTapped() {
        
    }
}

#Preview {
    PriceCustomAttributeView(
        mode: .edit,
        store: .init(payload: ["currencyCode":"EUR", "price":"20.00"])
    )
}

class PriceCustomAttributeStore {
    
    // MARK: - Properties -
    
    /// Raw data source of the attribute
    private(set) var payload = [String: String]()
    
    /// Currency code of the price
    /// E.g.: "USD", "EUR"
    var currencyCode: String {
        didSet { payload["currencyCode"] = currencyCode }
    }
    
    /// Price value in decimal format.
    var price: Decimal {
        didSet { payload["price"] = "\(price)" }
    }
    
    // MARK: - Init -
    
    init(payload: [String: String]) {
        guard let code = payload["currencyCode"],
              let rawPrice = payload["price"],
              let doublePrice = Double(rawPrice)
        else {
            fatalError("Invalid payload")
        }
        self.currencyCode = code
        self.price =  Decimal(doublePrice)
    }
    

}
