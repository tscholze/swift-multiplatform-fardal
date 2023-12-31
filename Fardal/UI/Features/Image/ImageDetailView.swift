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

    private let imageModel: ImageModel
    private let intialViewMode: ViewMode

    // MARK: - System properties -

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the view mode and the datasource.
    init(initialState: ViewInitalState<ImageModel>) {
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
            
            if let item = imageModel.item {
                makeLinkedSection(for: item)
            }
            
            makeTagsSection()
            makeActionsSection()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - View builders -

extension ImageDetailView {
    @ViewBuilder
    private func makeImageSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            HStack {
                Spacer()
       
            imageModel.image
                .resizable()
                .clipShape(Theme.Shape.roundedRectangle1)
                .shadow(radius: Theme.Shadow.radius1)
                .frame(width: 200, height: 200)
                
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func makeInformationSection() -> some View {
        Section("ImageDetail.Section.Information.Title") {
            LabeledContent(
                "ImageDetail.Section.Information.CreatedAt",
                value: imageModel.createdAt.formatted(date: .numeric, time: .omitted)
            )

            LabeledContent(
                "ImageDetail.Section.Information.Source",
                value: imageModel.source.rawValue.localizedCapitalized
            )
        }
    }

    @ViewBuilder
    private func makeLinkedSection(for item: ItemModel) -> some View {
        Section("ImageDetail.Section.Usage.Title") {
            ItemNavigationLink(item: item)
        }
    }

    @ViewBuilder
    private func makeTagsSection() -> some View {
        Section("ImageDetail.Section.Tags.Title") {
            if let tags = imageModel.tags?.filter({ $0.mlConfidence > 0 }) {
                List(tags, id: \.self) { tag in
                    LabeledContent {
                        Text("\(Int(tag.mlConfidence * 100))%")
                    } label: {
                        Text(tag.title)
                    }
                }
            }
            else {
                Text("ImageDetail.Section.Tags.Empty.Hint")
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
    ImageDetailView(initialState: .read(.mocked(forImage: .mockPiMicro)))
}
