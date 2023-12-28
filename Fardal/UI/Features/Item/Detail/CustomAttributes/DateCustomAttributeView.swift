//
//  DateCustomAttributeView.swift
//  Fardal
//
//  Created by Tobias Scholze on 11.12.23.
//

import SwiftUI

/// Represents a custom item attribute which contains
/// a [Date] value.
struct DateCustomAttributeView: View {
    // MARK: - Properties -

    /// View mode for the view
    let mode: ViewMode

    /// Underlying data source
    let store: DateCustomAttributeStore

    // MARK: - States -

    @State private var title: String = ""
    @State private var selectedDate: Date = .now

    // MARK: - UI -

    var body: some View {
        if mode == .read {
            VStack(alignment: .leading) {
                // Title
                Text(store.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Date without time
                Text(
                    store.date,
                    format: Date.FormatStyle(date: .numeric, time: .omitted)
                )
            }
        }
        else {
            VStack(spacing: Theme.Spacing.none) {
                // Title
                TextField("Item.Detail.Attribute.Date.Title.Placeholder", text: $title)
                    .font(.caption)
                    .onChange(
                        of: title,
                        onTitleChanged(oldValue:newValue:)
                    )

                DatePicker(selection: $selectedDate, displayedComponents: .date) {
                    EmptyView()
                }
                .onChange(
                    of: selectedDate,
                    onDateChanged(oldValue:newValue:)
                )
            }
            .onAppear {
                title = store.title
                selectedDate = store.date
            }
        }
    }
}

// MARK: - Events -

extension DateCustomAttributeView {
    private func onTitleChanged(oldValue _: String, newValue: String) {
        store.title = newValue
    }

    private func onDateChanged(oldValue _: Date, newValue: Date) {
        store.date = newValue
    }
}

// MARK: - Store -

class DateCustomAttributeStore {
    // MARK: - Properties -

    /// Raw data source of the attribute
    private(set) var attribute: ItemCustomAttribute

    /// Title of the price attribute.
    /// E.g. "Bought at".
    var title: String {
        didSet { attribute.payload["title"] = title }
    }

    // Date timestamp
    var date: Date {
        didSet { attribute.payload["date"] = date.formatted(.dateTime) }
    }

    // MARK: - Init -

    init(attribute: ItemCustomAttribute) {
        // Validate payload
        guard let title = attribute.payload["title"],
              let rawDate = attribute.payload["date"],
              let date = try? Date(rawDate, strategy: .dateTime) else {
            fatalError("Invalid payload")
        }

        // Set properties
        self.attribute = attribute
        self.title = title
        self.date = date
    }
}

// MARK: - Preview -

#Preview {
    DateCustomAttributeView(
        mode: .create, store: .init(attribute: .emptyDateAttribute)
    )
}
