//
//  ItemDetailView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI
import PhotosUI

/// Represents a [View] that shows the detail of the model
/// and enables the user to perform CRUD operations on the [Item].
struct ItemDetailView: View {
    // MARK: - Private properties -

    private var item: Item?
    private let intialViewMode: ViewMode

    @State private var draft: ItemDraft
    @State private var viewMode: ViewMode = .read
    @State private var title = ""
    @State private var summary = ""
    @State private var showAddCustomAttributeSheet = false
    @State private var showAddMediaSheet = false
    @State private var showIconWizard = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedColor: Color = Color.clear
    @State private var imagesData = [ImageData]()
    @State private var imageSelection: PhotosPickerItem? = nil
    @State private var cameraImagesData = [Data]()
    @State private var iconData: Data? = nil
    @State private var cameraModel = CameraModel()
    @State private var isValid = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init -

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the viewMode and the datasource.
    init(initialState: ItemDetailViewInitalState) {
        switch initialState {
        case let .read(item):
            _draft = .init(initialValue: .from(item: item))
            self.item = item
            intialViewMode = .read

        case .create:
            _draft = .init(initialValue: .from(item: .empty))
            item = nil
            intialViewMode = .create

        case let .edit(item):
            _draft = .init(initialValue: .from(item: item))
            self.item = item
            intialViewMode = .edit
        }
    }

    // MARK: - UI -

    var body: some View {
        Form {
            makeRequiredSection()
            makePhotosSection()
            makeTaggingSection()
            makeCustomAttributesSection()
            makeActionsSection()
        }
        .onChange(of: cameraImagesData, onChangeOfCameraImagesData(oldValue:newValue:))
        .navigationBarBackButtonHidden(viewMode == .edit)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { makeToolbar() }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $imageSelection,
            photoLibrary: .shared()
        )
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(cameraImagesData: $cameraImagesData)
        }
        .alert("Item.Draft.Detail.Action.AddAttribute", isPresented: $showAddCustomAttributeSheet) {
            makeAddCustomAttributeAlertContent()
        }
        .alert("Item.Draft.Detail.Action.AddMedia", isPresented: $showAddMediaSheet) {
            makeAddMediaAlertContent()
        }
        .onAppear(perform: onViewAppear)
        .task {
            Task.detached {
                do {
                    try await cameraModel.initialize()
                }
                catch {
                    print("Camera init failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - View builders -

extension ItemDetailView {
    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("Item.Draft.Detail.Section.Required.Title") {
            // Name
            if viewMode == .read {
                Text(title)
                Text(summary)
            }
            else {
                TextField("Item.Draft.Detail.Section.Required.Name", text: $title)
                    .onChange(of: title, onTitleChanged(oldValue:newValue:))

                // Summary
                TextField("Item.Draft.Detail.Section.Required.Summary", text: $summary)
                    .onChange(of: summary, onSummaryChanged(oldValue:newValue:))
            }
        }
    }

    @ViewBuilder
    private func makeTaggingSection() -> some View {
        Section("Item.Draft.Detail.Section.Tagging.Title") {
            // Color
            HStack(alignment: .center) {
                Text("Item.Draft.Detail.Section.Tagging.Flag")

                // Identicator
                Image(systemName: "flag.fill")
                    .foregroundStyle(Color(hex: draft.hexColor))

                // Color picker button if is in edit mode
                if viewMode != .read {
                    // Picker
                    ColorPicker("", selection: $selectedColor)
                        .onChange(of: selectedColor) { _, newValue in
                            draft.hexColor = newValue.hexValue
                        }
                }
            }
        }
    }

    @ViewBuilder
    private func makePhotosSection() -> some View {
        Section {
            // Show how to add images hint if list is empty
            if imagesData.isEmpty {
                makeEmptyImagesHint()
                    .frame(height: 60)
            }
            else {
                ScrollView(.horizontal) {
                    HStack {
                        // Live camera feed
                        // Determine if this feature is useable and how
                        // CameraPreview(cameraModel: cameraModel)
                        //    .frame(width: 60, height: 60)
                        //    .clipShape(RoundedRectangle(cornerRadius: 4))
                        //

                        // List of images
                        ForEach(imagesData, id: \.id) { imageData in
                            // Render image
                            Image(uiImage: imageData.uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(alignment: .topTrailing) {
                                    // Show delete button in case of edit / create
                                    // is enabled
                                    if viewMode != .read {
                                        Button {
                                            imagesData.removeAll(where: { $0.id == imageData.id })
                                        } label: {
                                            Image(systemName: "x.circle.fill")
                                                .foregroundStyle(.white)
                                                .opacity(0.6)
                                                .shadow(radius: 2)
                                                .padding(4)
                                        }
                                    }
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            }
        } header: {
            HStack {
                Text("Item.Draft.Detail.Section.Photos.Title \(draft.imagesData.count) / \(FardalConstants.Item.maxNumberOfPhotosPerItem)")
                if viewMode != .read {
                    HStack {
                        Spacer()
                        Button {
                            showAddMediaSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                        }.disabled(draft.imagesData.count == FardalConstants.Item.maxNumberOfPhotosPerItem)
                    }
                }
            }
            .sheet(isPresented: $showIconWizard) {
                SymbolWizardView(selectedData: $iconData)
            }
        } footer: {
            Text("Item.Draft.Section.Photos.Footer")
        }
        .onChange(of: iconData) { n, o in
            onIconDataChanged(oldValue: n, newValue: o)
        }
        .onChange(of: imageSelection, onChangeImageSelection(oldValue:newValue:))
        .onChange(of: imagesData) { draft.imagesData = $1 }
    }

    @ViewBuilder
    private func makeEmptyImagesHint() -> some View {
        HStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.Photo.Empty.Camera.Hint")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }

            Divider()

            VStack(spacing: 8) {
                Image(systemName: "rectangle.center.inset.filled.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.Photo.Empty.Icon.Hint")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                Image(systemName: "photo.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.Photo.Empty.Library.Hint")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
        }
        .foregroundStyle(.secondary)
        .opacity(0.6)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func makeCustomAttributesSection() -> some View {
        Section {
            Group {
                if draft.customAttributes.isEmpty {
                    makeEmptyCustomAttributeHint()
                }
                else {
                    List {
                        ForEach(draft.customAttributes) { attribute in
                            ItemCustomAttributeTypes(rawValue: attribute.layout)?
                                .makeView(for: attribute, with: viewMode)
                        }
                        .onDelete(perform: onDeleteCustomTapped)
                        .deleteDisabled(viewMode == .read)
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        return 0
                    }
                }
            }
            .frame(minHeight: 60)
        } header: {
            HStack {
                Text("Item.Draft.Detail.Section.Attributes.Title")
                if viewMode != .read {
                    Spacer()

                    Button(
                        action: { onAddCustomTapped() },
                        label: {
                            Image(systemName: "plus.circle")
                        }
                    )
                }
            }
        } footer: {
            Text("Item.Draft.Detail.Section.Attributes.Footer")
        }
    }

    @ViewBuilder
    private func makeEmptyCustomAttributeHint() -> some View {
        HStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemSymbol: .eurosignCircle)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.CustomAttributes.Empty.Pricing.Hint")
            }

            Divider()

            VStack(spacing: 8) {
                Image(systemSymbol: .calendar)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.CustomAttributes.Empty.Dates.Hint")
            }

            Divider()

            VStack(spacing: 8) {
                Image(systemSymbol: .safari)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.CustomAttributes.Empty.Url.Hint")
            }

            Divider()

            VStack(spacing: 8) {
                Image(systemSymbol: .ellipsisCircle)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                Text("Item.Draft.Detail.Section.CustomAttributes.Empty.More.Hint")
            }
        }
        .multilineTextAlignment(.center)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .opacity(0.6)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func makeActionsSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            if let modelId = draft.existingId {
                HStack {
                    Spacer()
                    Button("Item.Draft.Detail.Actions.DeleteItem", role: .destructive) {
                        ItemDatabaseOperations.shared.delete(withId: modelId)
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeAddCustomAttributeAlertContent() -> some View {
        // Date
        Button("Item.Draft.Detail.Action.AddDateAttribute") {
            onAddDateCustomAttributeTapped()
        }

        // Price
        Button("Item.Draft.Detail.Action.AddPriceAttribute") {
            onAddPriceCustomAttributeTapped()
        }

        // Url
        Button("Item.Draft.Detail.Action.AddUrlAttribute") {
            onAddUrlCustomAttributeTapped()
        }

        // Url
        Button("Item.Draft.Detail.Action.AddNoteAttribute") {
            onAddNoteCustomAttributeTapped()
        }

        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }

    @ViewBuilder
    private func makeAddMediaAlertContent() -> some View {
        // Photo picker
        Button("Item.Draft.Action.SelectPhoto") {
            showPhotoPicker.toggle()
        }

        // Camera
        Button("Item.Draft.Action.TakePhoto") {
            showCamera.toggle()
        }

        // Icon wizard
        Button("Item.Draft.Action.AddCustomIcon") {
            showIconWizard.toggle()
        }

        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }

    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        if viewMode == .read {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewMode = .edit }) {
                    Text("Item.Draft.Action.Edit")
                }
            }
        }
        else {
            if viewMode != .create {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { onCancelTapped() }) {
                        Text("Item.Draft.Action.Cancel")
                    }
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: { onSaveButtonTapped() }) {
                    VStack {
                        Text("Item.Draft.Action.Save")
                        Text(isValid ? "Valid" : "Invalid")
                    }
                }
                .disabled(isValid == false)
            }
        }
    }
}

// MARK: - Actions -

extension ItemDetailView {
    private func isValidInput() -> Bool {
        if title.isEmpty || summary.isEmpty {
            return false
        }
        else {
            return true
        }
    }

    private func onViewAppear() {
        viewMode = intialViewMode
        selectedColor = Color(hex: draft.hexColor)
        imagesData = draft.imagesData
    }

    private func onTitleChanged(oldValue _: String, newValue: String) {
        isValid = isValidInput()
        if isValid {
            draft.title = newValue
        }
    }

    private func onSummaryChanged(oldValue _: String, newValue: String) {
        isValid = isValidInput()
        if isValid {
            draft.summary = newValue
        }
    }

    private func onChangeOfCameraImagesData(oldValue _: [Data], newValue: [Data]) {
        newValue.forEach { data in
            imagesData.append(.init(data: data))
        }
    }

    private func onChangeImageSelection(oldValue _: PhotosPickerItem?, newValue: PhotosPickerItem?) {
        guard let newValue else { return }

        newValue.loadTransferable(type: Data.self) { result in
            switch result {
            case let .success(.some(data)):
                let newImage = ImageData(data: data)
                imagesData.append(newImage)
            default: print("Failed")
            }
        }
    }

    private func onIconDataChanged(oldValue _: Data?, newValue: Data?) {
        guard let newValue else { return }
        imagesData.insert(.init(data: newValue), at: 0)
    }

    private func onCancelTapped() {
        if let item {
            draft = .from(item: item)
            selectedColor = Color(hex: draft.hexColor)
            imagesData = draft.imagesData
            viewMode = .read
        }
        else {
            dismiss()
        }
    }

    private func onAddIconTapped() {
        showIconWizard.toggle()
    }

    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddPriceCustomAttributeTapped() {
        draft.customAttributes.append(.emptyPriceAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddDateCustomAttributeTapped() {
        draft.customAttributes.append(.emptyDateAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddUrlCustomAttributeTapped() {
        draft.customAttributes.append(.emptyUrlAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddNoteCustomAttributeTapped() {
        draft.customAttributes.append(.emptyNoteAttribute)
    }

    private func onDeleteCustomTapped(withIndexSet indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let attribute = draft.customAttributes[index]
        draft.customAttributes.removeAll(where: { $0.id == attribute.id })
    }

    private func onSaveButtonTapped() {
        if let item {
            // Remove attributes from database which are deleted in drafts
            item.customAttributes.forEach { itemAttribute in
                if draft.customAttributes.contains(itemAttribute) == false {
                    modelContext.delete(itemAttribute)
                }
            }

            item.title = draft.title
            item.summary = draft.summary
            item.customAttributes = draft.customAttributes
            item.hexColor = draft.hexColor
            item.imageDatas = draft.imagesData
            item.updatedAt = .now
            viewMode = .read
        }
        else {
            let newItem = Item(
                title: draft.title,
                summary: draft.summary,
                hexColor: draft.hexColor,
                imagesData: draft.imagesData,
                // customAttributes: draft.customAttributes,
                updatedAt: .now
            )

            modelContext.insert(newItem)
            dismiss()
        }
    }

    private func onEditButtonTapped() {
        viewMode = .edit
    }
}

extension ItemDetailView {
    private func validateInput() {
        if title.isEmpty || summary.isEmpty {
            isValid = false
        }
        else {
            isValid = true
        }
    }
}

// MARK: - Preview -

#Preview {
    NavigationView {
        ItemDetailView(initialState: .create)
    }
}
