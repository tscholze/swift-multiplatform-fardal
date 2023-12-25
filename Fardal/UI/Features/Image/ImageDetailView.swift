//
//  ImageDetailView.swift
//  Fardal
//
//  Created by Tobias Scholze on 25.12.23.
//

import SwiftUI
import SwiftData

/// Represents a [View] that shows the detail of the model
struct ImageDetailView: View {
    // MARK: - Private properties -

    private let imageModel: ImageDataModel
    private let intialViewMode: ViewMode

    // MARK: - System -

    // SwiftData does not support UUID, wtf.
    @Query private var items: [ItemModel]
    @State private var item: ItemModel?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the view mode and the datasource.
    init(initialState: ViewInitalState<ImageDataModel>) {
        switch initialState {
        case let .read(imageModel):
            self.imageModel = imageModel
            intialViewMode = .read

        default:
            fatalError("Not supported")
        }
    }

    // MARK: - UI -

    var body: some View {
        Form {
            makeImageSection()
            makeInformationSection()

            if let item {
                makeLinkedSection(for: item)
            }
            
            makeActionsSection()
        }
        .onAppear {
            // Mocking fix for not being able to get item via SwiftData
            item = items.first
        }
    }
}

// MARK: - View builders -

extension ImageDetailView {
    private func makeImageSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            imageModel.image
                .resizable()
                .clipShape(Theme.Shape.roundedRectangle1)
                .shadow(radius: 10)
                .frame(width: 300, height: 300)
        }
    }

    private func makeInformationSection() -> some View {
        Section("ImageDetail.Section.Information.Title") {
            LabeledContent(
                "ImageDetail.Section.Information.CreatedAt",
                value: imageModel.createdAt.formatted(date: .numeric, time: .omitted)
            )
            
            LabeledContent(
                "ImageDetail.Section.Information.Source",
                value: imageModel.source.rawValue
            )
        }
    }

    private func makeLinkedSection(for item: ItemModel) -> some View {
        Section("ImageDetail.Section.Usage.Title") {
            NavigationLink(item.title) {
                ItemDetailView(initialState: .read(item))
            }
        }
    }

    private func makeActionsSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            HStack {
                Spacer()
                Button("ImageDetail.Actions.DeleteImage", role: .destructive) {
                    modelContext.delete(imageModel)
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    ImageDetailView(initialState: .read(.mockedPhoto))
}
