//
//  SymbolPickerView.swift
//  Fardal
//
//  Created by Tobias Scholze on 17.12.23.
//

import SwiftUI
import SFSafeSymbols

struct SymbolPickerView: View {
    
    // MARK: - Properties -
    
    let tintColor: Color
    let backgroundColor: Color
    @Binding var selectedSymbolName: String
    
    // MARK: - Private properties -
    
    private let allSymbols = Array(SFSymbol.allSymbols).sorted(by: { $0.rawValue < $1.rawValue })
    @State private var searchQuery = ""
    @State private var filteredSymbols = [SFSymbol]()
    @Environment(\.dismiss) var dismiss
    
    // MARK: - UI -
    
    var body: some View {
        VStack {
            // Serach field
            TextField("SymbolPicker.SearchQuery.Title", text: $searchQuery)
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
                        .tint(tintColor)
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
    private func onSearchQueryChanged(oldValue: String, newValue: String) {
        if newValue.isEmpty {
            filteredSymbols = allSymbols
        } else {
            filteredSymbols = allSymbols.filter { symbol in
                symbol.rawValue.contains(newValue)
            }
        }
    }
    
    private func onSymbolSelected(symbol: SFSymbol) {
        selectedSymbolName = symbol.rawValue
        dismiss()
    }
}

#Preview {
    @State var name: String = ""
    
    return SymbolPickerView(
        tintColor: .orange, 
        backgroundColor: .gray,
        selectedSymbolName: $name
    )
}


extension SFSymbol: Identifiable {
    
}
