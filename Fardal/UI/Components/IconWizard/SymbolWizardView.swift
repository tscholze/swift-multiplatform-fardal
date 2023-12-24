//
//  SymbolWizardView.swift
//  Fardal
//
//  Created by Tobias Scholze on 17.12.23.
//

import SwiftUI
import SFSafeSymbols

/// Enables the user to create an System symbol with
/// customized symbol, fore- and background color.
struct SymbolWizardView: View {
    // MARK: - Properties -

    /// `Data` representation of  user's selected symbol
    @Binding var selectedData: Data?

    // MARK: - Private properties -

    @State private var selectedSymbolName: String = ""
    @State private var selectedColor: Color = .accentColor
    @State private var selectedBackgroundColor: Color = .clear
    @Environment(\.dismiss) var dismiss

    // MARK: - UI -

    var body: some View {
        NavigationView {
            Form {
                makeIconSelectionSection()
                makeColorSection()
                makePreviewSection()
            }
            .toolbar { makeToolbar() }
            .navigationTitle("SymbolWizard.Title")
        }
    }
}

// MARK: - Actions -

extension SymbolWizardView {
    @MainActor
    private func onSelectTapped() {
        let symbol = makeSymbol(size: 256)
        guard let cgImage = ImageRenderer(content: symbol).cgImage else {
            print("Error: Could not create CGImage.")
            return
        }

        guard let data = UIImage(cgImage: cgImage).pngData() else {
            print("Error: Could not create data from UIImage from CGImage")
            return
        }

        selectedData = data
        dismiss()
    }
}

// MARK: - View builders -

extension SymbolWizardView {
    @MainActor
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("SymbolWizard.Action.Select") {
                onSelectTapped()
            }
        }
    }

    @ViewBuilder
    private func makeIconSelectionSection() -> some View {
        Section("SymbolWizard.Section.Icon") {
            NavigationLink {
                SymbolPickerView(
                    selectedSymbolName: $selectedSymbolName,
                    foregroundColor: selectedColor,
                    backgroundColor: selectedBackgroundColor
                )
            } label: {
                HStack {
                    Text("SymbolWizard.Section.Icon.Hint")

                    Spacer()

                    if selectedSymbolName.isEmpty == false {
                        Image(systemName: selectedSymbolName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .foregroundStyle(selectedColor)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeColorSection() -> some View {
        Section("SymbolWizard.Section.Color") {
            ColorPicker(selection: $selectedColor) {
                Text("SymbolWizard.Section.Color.Hint")
                    .foregroundStyle(
                        selectedSymbolName.isEmpty ? .secondary : .primary
                    )
            }
            .disabled(selectedSymbolName.isEmpty)

            ColorPicker(selection: $selectedBackgroundColor) {
                Text("SymbolWizard.Section.BackgroundColor.Hint")
                    .foregroundStyle(
                        selectedSymbolName.isEmpty ? .secondary : .primary
                    )
            }
            .disabled(selectedSymbolName.isEmpty)
        }
    }

    @ViewBuilder
    private func makePreviewSection() -> some View {
        Section("SymbolWizard.Section.Preview") {
            VStack(alignment: .center) {
                makeSymbol(size: 100)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func makeSymbol(size: CGFloat) -> some View {
        ZStack(alignment: .center) {
            Theme.Shape.roundedRectangle2
                .foregroundStyle(selectedBackgroundColor)

            Image(systemName: selectedSymbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(selectedColor)
                .padding()
                .frame(width: size * 0.90)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview -

#Preview {
    @State var data: Data?
    return SymbolWizardView(selectedData: $data)
}
