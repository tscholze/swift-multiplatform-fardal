//
//  SearchView.swift
//  Fardal
//
//  Created by Tobias Scholze on 05.01.24.
//

import Vision
import SwiftUI
import SwiftData

/// Enables the user to search for data objects
struct SearchView: View {
    // MARK: - Private properties -

    @ObservedObject private var cameraModel = CameraModel()
    @State private var filteredCollections = [CollectionModel]()

    // MARK: - Database properties -

    @Query private var collections: [CollectionModel]

    // MARK: - UI -

    var body: some View {
        NavigationView {
            Form {
                Section {
                    EmptyView()
                } footer: {
                    CameraPreview(cameraModel: cameraModel)
                        .clipShape(Theme.Shape.roundedRectangle1)
                        .shadow(radius: Theme.Shadow.radius1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                }

                Section("SearchByCode.Section.Found.Collections") {
                    if filteredCollections.isEmpty {
                        Text("SearchByCode.Section.Found.Collections.Empty.Hint")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    else {
                        List(filteredCollections) { collection in
                            NavigationLink(collection.title) {
                                CollectionDetailView(initialState: .read(collection))
                            }
                        }
                    }
                }
            }
            .navigationTitle("SearchByCode.Title")
            .task { try? await cameraModel.initialize(modes: [.text, .autoscan]) }
            .onDisappear { cameraModel.deinitialize() }
            .onChange(
                of: cameraModel.recognizedWords,
                onRecognizedWordsChanged(oldValue:newValue:)
            )
        }
    }
}

// MARK: - Actions -

extension SearchView {
    private func onRecognizedWordsChanged(oldValue _: [String], newValue: [String]) {
        guard let firstKeyword = newValue.first else {
            return
        }

        filteredCollections = collections.filter {
            guard let customId = $0.customId else { return false }
            return customId.localizedStandardContains(firstKeyword)
        }
    }
}
