//
//  SymbolPickerView.swift
//  Fardal
//
//  Created by Tobias Scholze on 17.12.23.
//

import SwiftUI
import SFSafeSymbols

/// Grid-based System symbol picker with
/// setable fore- and background color
struct SymbolPickerView: View {
    // MARK: - Properties -

    @Binding var selectedSymbolName: String

    let foregroundColor: Color
    let backgroundColor: Color

    // MARK: - Private properties -

    private let allSymbols = Array(SFSymbol.allSymbols).sorted(by: { $0.rawValue < $1.rawValue })

    // MARK: - System properties -

    @Environment(\.dismiss) var dismiss

    // MARK: - States -

    @State private var searchQuery = ""
    @State private var filteredSymbols = [SFSymbol]()

    // MARK: - UI -

    var body: some View {
        VStack {
            // Serach field
            TextField("SymbolPicker.SearchQuery.Title", text: $searchQuery)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(
                    of: searchQuery,
                    onSearchQueryChanged(oldValue:newValue:)
                )

            // List of filtered symbols
            ScrollView {
                LazyVGrid(columns: [.init(), .init(), .init()]) {
                    ForEach(filteredSymbols) { symbol in
                        Button(action: { onSymbolSelected(symbol: symbol) }) {
                            Image(systemSymbol: symbol)
                                .resizable()
                                .frame(width: 44, height: 44)
                                .scaledToFit()
                                .padding()
                        }
                        .background(backgroundColor)
                        .tint(foregroundColor)
                    }
                }
            }
        }
        .onAppear { filteredSymbols = allSymbols }
        .navigationTitle("SymbolPicker.Title")
    }
}

// MARK: - Actions -

extension SymbolPickerView {
    private func onSearchQueryChanged(oldValue _: String, newValue: String) {
        if newValue.isEmpty {
            filteredSymbols = allSymbols
        }
        else {
            let lowercasedQuery = newValue.lowercased()
            filteredSymbols = allSymbols.filter { symbol in
                symbol.rawValue.contains(lowercasedQuery)
            }
        }
    }

    private func onSymbolSelected(symbol: SFSymbol) {
        selectedSymbolName = symbol.rawValue
        dismiss()
    }
}

// MARK: - Preview -

#Preview {
    @State var name: String = ""

    return SymbolPickerView(
        selectedSymbolName: $name,
        foregroundColor: .orange,
        backgroundColor: .gray
    )
}

extension SFSymbol: Identifiable {}
