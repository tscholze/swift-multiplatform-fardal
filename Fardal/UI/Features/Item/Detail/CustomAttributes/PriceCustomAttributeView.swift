//
//  PriceCustomAttributeView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI

/// Represents a custom item attribute which contains pricing
/// information with a selectable currency
struct PriceCustomAttributeView: View {
    // MARK: - Properties -

    /// View mode for the view
    let mode: ViewMode

    /// Data store whichs information shall be rendered
    let store: PriceCustomAttributeStore

    // MARK: - States -

    @State private var title: String = ""
    @State private var price: Decimal = 0
    @State private var selectedCurrencyCode = "EUR"

    // MARK: - UI -

    var body: some View {
        switch mode {
        case .read:
            makeReadView()
        case .create, .edit:
            makeWriteableView()
        }
    }
}

// MARK: - View Builders -

extension PriceCustomAttributeView {
    @ViewBuilder
    private func makeReadView() -> some View {
        VStack(alignment: .leading) {
            Text(store.title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(store.price, format: .currency(code: store.currencyCode))
        }
    }

    @ViewBuilder
    private func makeWriteableView() -> some View {
        VStack(spacing: Theme.Spacing.none) {
            // Title
            TextField("Item.Detail.Attribute.Price.Title", text: $title)
                .font(.caption)
                .onChange(
                    of: title,
                    onTitleChanged(oldValue:newValue:)
                )

            // Price and Currency chooser
            HStack {
                // Value
                TextField(
                    "Item.Detail.Attribute.Price.Value.Placeholder",
                    value: $price, format: .currency(code: selectedCurrencyCode)
                )
                .keyboardType(.decimalPad)
                .onChange(
                    of: price,
                    onPriceChanged(oldValue:newValue:)
                )

                Spacer()

                Picker("", selection: $selectedCurrencyCode) {
                    ForEach(SupportedCurrencies.allCases) { currency in
                        if let name = Locale.current.localizedString(forCurrencyCode: currency.code) {
                            Text(name).tag(currency.code)
                        }
                        else {
                            EmptyView()
                        }
                    }
                }
                .onChange(
                    of: selectedCurrencyCode,
                    onCurrencyCodeChanged(oldValue:newValue:)
                )
            }
        }
        .onAppear {
            title = store.title
            price = store.price
            selectedCurrencyCode = store.currencyCode
        }
    }
}

// MARK: - Actions -

extension PriceCustomAttributeView {
    private func onTitleChanged(oldValue _: String, newValue: String) {
        store.title = newValue
    }

    private func onCurrencyCodeChanged(oldValue _: String, newValue: String) {
        store.currencyCode = newValue
    }

    private func onPriceChanged(oldValue _: Decimal, newValue: Decimal) {
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
        guard let title = attribute.payload["title"],
              let code = attribute.payload["currencyCode"],
              let rawPrice = attribute.payload["price"],
              let doublePrice = Double(rawPrice) else {
            fatalError("Invalid payload")
        }

        // Set properties
        self.attribute = attribute
        self.title = title
        currencyCode = code
        price = Decimal(doublePrice)
    }
}

// MARK: - Preview -

#Preview {
    PriceCustomAttributeView(
        mode: .edit,
        store: .init(attribute: ItemCustomAttribute.emptyPriceAttribute)
    )
}
