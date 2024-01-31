//
//  ItemDetailView.swift
//  Fardal
//
//  Created by Tobias Scholze on 10.12.23.
//

import SwiftUI
import PhotosUI
import SwiftData

/// Represents a [View] that shows the detail of the model
/// and enables the user to perform CRUD operations on the [Item].
struct ItemDetailView: View {
    // MARK: - Private properties -

    @Bindable private var item: ItemModel
    private let intialViewMode: ViewMode

    // MARK: - System properties -

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Presenation states -

    @State private var viewMode: ViewMode = .read
    @State private var showAddCollectionAlert = false
    @State private var showAddCollectionSheet = false
    @State private var showLinkCollectionSheet = false
    @State private var showAddCustomAttributeSheet = false
    @State private var showAddMediaSheet = false
    @State private var showIconWizard = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var isValid = false

    // MARK: - Intermitten states -

    @State private var imageSelection: PhotosPickerItem? = nil
    @State private var cameraImagesData = [ImageModel]()

    // MARK: - Draft states -

    @State private var iconData: Data? = nil

    // MARK: - Init -

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the view mode and the datasource.
    init(initialState: ViewInitalState<ItemModel>) {
        switch initialState {
        case let .read(item):
            self.item = item
            intialViewMode = .read

        case .create:
            item = .init(title: "", summary: "")
            intialViewMode = .create

        case let .edit(item):
            self.item = item
            intialViewMode = .edit
        }
    }

    // MARK: - UI -

    var body: some View {
        Form {
            makeRequiredSection()
            makeCollectionSection()
            makePhotosSection()
            makeTaggingSection()
            makeCustomAttributesSection()
            makeActionsSection()
        }
        .navigationBarBackButtonHidden(viewMode != .read)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: makeToolbar)
        .onAppear(perform: onViewAppear)
        .onChange(
            of: cameraImagesData,
            onChangeOfCameraImagesData(oldValue:newValue:)
        )
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $imageSelection,
            photoLibrary: .shared()
        )
        .fullScreenCover(
            isPresented: $showCamera,
            content: { CameraPicker(cameraImagesData: $cameraImagesData) }
        )
        .alert(
            "ItemDetail.Action.AddAttribute",
            isPresented: $showAddCustomAttributeSheet,
            actions: { makeAddCustomAttributeAlertContent() }
        )
        .alert(
            "ItemDetail.Action.AddMedia",
            isPresented: $showAddMediaSheet,
            actions: { makeAddMediaAlertContent() }
        )
        .alert(
            "ItemDetail.Action.AddCollection",
            isPresented: $showAddCollectionAlert,
            actions: { makeAddCollectionAlertContent() }
        )
        .sheet(
            isPresented: $showLinkCollectionSheet,
            content: { ItemDetailLinkCollectionView(selectedCollection: $item.collection) }
        )
        .sheet(
            isPresented: $showAddCollectionSheet,
            content: { NavigationView { CollectionDetailView(initialState: .create) } }
        )
    }
}

// MARK: - View builders -

extension ItemDetailView {
    @ViewBuilder
    private func makeRequiredSection() -> some View {
        Section("ItemDetail.Section.Required.Title") {
            if viewMode == .read {
                Text(item.title)
                Text(item.summary)
            }
            else {
                VStack(alignment: .leading) {
                    // Name
                    TextField(
                        "ItemDetail.Section.Required.Name",
                        text: $item.title
                    )
                    .onChange(of: item.title) {
                        updateInputValidity()
                    }

                    Divider()

                    // Summary
                    TextField(
                        "ItemDetail.Section.Required.Summary",
                        text: $item.summary
                    )
                    .onChange(of: item.summary) {
                        updateInputValidity()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeCollectionSection() -> some View {
        Section {
            if let collection = item.collection {
                NavigationLink {
                    CollectionDetailView(initialState: .read(collection))
                } label: {
                    HStack(spacing: Theme.Spacing.medium) {
                        collection.coverImage
                            .resizable()
                            .clipShape(Theme.Shape.roundedRectangle2)
                            .frame(width: 60, height: 60)

                        VStack(alignment: .leading) {
                            Text(collection.title)
                            Text(collection.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            else {
                Hint(
                    titleKey: "ItemDetail.Section.Collection.Empty.Hint",
                    systemName: "doc.on.doc"
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            HStack {
                Text("ItemDetail.Section.Collection.Title")
                Spacer()

                if viewMode != .read {
                    Button(action: { onAddCollectionTapped() }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeTaggingSection() -> some View {
        Section("ItemDetail.Section.Tagging.Title") {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                // Flag
                HStack {
                    Group {
                        if let color = item.color {
                            Theme.Shape.roundedRectangle2
                                .fill(color)
                                .shadow(radius: Theme.Shadow.border)
                        }
                        else {
                            Theme.Shape.roundedRectangle2
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                                .opacity(0.5)
                        }
                    }
                    .frame(width: 72, height: 72, alignment: .topLeading)

                    OptionalColorPicker(
                        selectedColor: $item.color,
                        selectableColors:
                        Theme.Colors.pastelColors
                    )
                    .disabled(viewMode == .read)
                }

                /// Divider()
                ///
                /// // Tags / Chips
                /// ChipsView(chips: $item.tags.map { ChipModel(title: $0) }, viewMode: $viewMode)
                ///
                /// 
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func makePhotosSection() -> some View {
        Section {
            // Show how to add images hint if list is empty
            if let images = item.imagesData, images.isEmpty == false {
                ScrollView(.horizontal) {
                    HStack {
                        // Live camera feed
                        // Determine if this feature is useable and how
                        // CameraPreview(cameraModel: cameraModel)
                        //    .frame(width: 60, height: 60)
                        //    .clipShape(RoundedRectangle(cornerRadius: 4))
                        //

                        // List of images
                        ForEach(item.imagesData ?? [], id: \.id) { imageData in
                            // Render image
                            Image(uiImage: imageData.uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .clipShape(Theme.Shape.roundedRectangle2)
                        }

                        // TODO: Add Image deletion button
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            }
            else {
                makeEmptyImagesHint()
                    .frame(height: 60)
            }
        } header: {
            HStack {
                Text("ItemDetail.Section.Photos.Title \(item.numberOfImages) / \(FardalConstants.Item.maxNumberOfPhotosPerItem)")
                if viewMode != .read {
                    HStack {
                        Spacer()
                        Button {
                            showAddMediaSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(item.imagesData?.count == FardalConstants.Item.maxNumberOfPhotosPerItem)
                    }
                }
            }
            .sheet(isPresented: $showIconWizard) {
                SymbolWizardView(selectedData: $iconData)
            }
        } footer: {
            Text("ItemDetail.Section.Photos.Footer")
        }
        .onChange(of: iconData, onIconDataChanged(oldValue:newValue:))
        .onChange(of: imageSelection, onChangeImageSelection(oldValue:newValue:))
    }

    @ViewBuilder
    private func makeEmptyImagesHint() -> some View {
        HStack(spacing: Theme.Spacing.large) {
            Hint(
                titleKey: "ItemDetail.Section.Photo.Empty.Camera.Hint",
                systemName: "camera.viewfinder"
            )

            Divider()

            Hint(
                titleKey: "ItemDetail.Section.Photo.Empty.Library.Hint",
                systemName: "photo.badge.plus"
            )

            Divider()

            Hint(
                titleKey: "ItemDetail.Section.Photo.Empty.Icon.Hint",
                systemName: "rectangle.center.inset.filled.badge.plus"
            )
        }
        .foregroundStyle(.secondary)
        .opacity(0.6)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func makeCustomAttributesSection() -> some View {
        Section {
            Group {
                if item.customAttributes?.isEmpty == true {
                    makeEmptyCustomAttributeHint()
                }
                else {
                    List {
                        ForEach(item.customAttributes ?? []) { attribute in
                            ItemCustomAttributeType(rawValue: attribute.layout)?
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
                Text("ItemDetail.Section.Attributes.Title")
                if viewMode != .read {
                    Spacer()

                    Button(
                        action: { onAddCustomTapped() },
                        label: { Image(systemName: "plus.circle") }
                    )
                }
            }
        } footer: {
            Text("ItemDetail.Section.Attributes.Footer")
        }
    }

    @ViewBuilder
    private func makeEmptyCustomAttributeHint() -> some View {
        HStack(spacing: Theme.Spacing.large) {
            Hint(
                titleKey: "ItemDetail.Section.CustomAttributes.Empty.Pricing.Hint",
                systemName: "eurosign.circle"
            )

            Divider()

            Hint(
                titleKey: "ItemDetail.Section.CustomAttributes.Empty.Dates.Hint",
                systemName: "calendar"
            )

            Divider()

            Hint(
                titleKey: "ItemDetail.Section.CustomAttributes.Empty.Url.Hint",
                systemName: "safari"
            )

            Divider()

            Hint(
                titleKey: "ItemDetail.Section.CustomAttributes.Empty.More.Hint",
                systemName: "ellipsis.circle"
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func makeActionsSection() -> some View {
        Section {
            EmptyView()
        } header: {
            EmptyView()
        } footer: {
            if viewMode != .create {
                HStack {
                    Spacer()
                    Button("ItemDetail.Actions.DeleteItem", role: .destructive) {
                        modelContext.delete(item)
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeAddCustomAttributeAlertContent() -> some View {
        // Date
        Button("ItemDetail.Action.AddDateAttribute") {
            onAddDateCustomAttributeTapped()
        }

        // Price
        Button("ItemDetail.Action.AddPriceAttribute") {
            onAddPriceCustomAttributeTapped()
        }

        // Url
        Button("ItemDetail.Action.AddUrlAttribute") {
            onAddUrlCustomAttributeTapped()
        }

        // Url
        Button("ItemDetail.Action.AddNoteAttribute") {
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
        Button("ItemDetail.Action.SelectPhoto") {
            showPhotoPicker.toggle()
        }

        // Camera
        Button("ItemDetail.Action.TakePhoto") {
            showCamera.toggle()
        }

        // Icon wizard
        Button("ItemDetail.Action.AddCustomIcon") {
            showIconWizard.toggle()
        }

        // Cancel
        Button("Misc.Cancel", role: .cancel) {
            // nothing
        }
    }

    @ViewBuilder
    private func makeAddCollectionAlertContent() -> some View {
        // Photo picker
        Button("ItemDetail.Action.CreateCollection") {
            showAddCollectionSheet.toggle()
        }

        // Camera
        Button("ItemDetail.Action.AssignCollection") {
            showLinkCollectionSheet.toggle()
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
                    Text("ItemDetail.Action.Edit")
                }
            }
        }
        else {
            // Cancel button
            if viewMode != .read {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { onCancelTapped() }) {
                        Text("ItemDetail.Action.Cancel")
                    }
                }
            }

            // Save button
            ToolbarItem(placement: .primaryAction) {
                Button(
                    "ItemDetail.Action.Save",
                    action: onSaveButtonTapped
                )
                .disabled(isValid == false)
            }
        }
    }
}

// MARK: - Actions -

extension ItemDetailView {
    private func updateInputValidity() {
        isValid = if item.title.isEmpty || item.summary.isEmpty {
            false
        }
        else {
            true
        }
    }

    private func onViewAppear() {
        viewMode = intialViewMode
        updateInputValidity()
    }

    private func onChangeOfCameraImagesData(
        oldValue _: [ImageModel],
        newValue: [ImageModel]
    ) {
        newValue.forEach { addImageData($0) }
    }

    private func onChangeImageSelection(
        oldValue _: PhotosPickerItem?,
        newValue: PhotosPickerItem?
    ) {
        guard let newValue else { return }

        newValue.loadTransferable(type: Data.self) { result in
            switch result {
            case let .success(.some(data)):
                let newImage = ImageModel(data: data)
                addImageData(newImage)
            default: print("Failed")
            }
        }
    }

    private func onIconDataChanged(
        oldValue _: Data?,
        newValue: Data?
    ) {
        guard let newValue else { return }
        addImageData(.init(data: newValue, source: .icon))
    }

    private func onCancelTapped() {
        switch viewMode {
        case .create: dismiss()
        case .read: dismiss()
        case .edit:
            while modelContext.undoManager?.canUndo == true {
                modelContext.undoManager?.undo()
            }
            viewMode = .read
        }
    }

    private func onAddCollectionTapped() {
        showAddCollectionAlert.toggle()
    }

    private func onAddIconTapped() {
        showIconWizard.toggle()
    }

    private func addImageData(_ imageData: ImageModel) {
        if item.imagesData == nil {
            item.imagesData = [imageData]
        }
        else {
            item.imagesData?.insert(imageData, at: 0)
        }
    }

    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddPriceCustomAttributeTapped() {
        addCustomAttribute(.emptyPriceAttribute)
    }

    private func onAddDateCustomAttributeTapped() {
        addCustomAttribute(.emptyDateAttribute)
    }

    private func onAddUrlCustomAttributeTapped() {
        addCustomAttribute(.emptyUrlAttribute)
    }

    private func onAddNoteCustomAttributeTapped() {
        addCustomAttribute(.emptyNoteAttribute)
    }

    private func addCustomAttribute(_ attribute: ItemCustomAttribute) {
        if item.customAttributes == nil {
            item.customAttributes = [attribute]
        }
        else {
            item.customAttributes?.append(attribute)
        }

        showAddCustomAttributeSheet.toggle()
    }

    private func onDeleteCustomTapped(withIndexSet indexSet: IndexSet) {
        guard let index = indexSet.first, let attribute = item.customAttributes?[index] else { return }

        item.customAttributes?.remove(at: index)
        modelContext.delete(attribute)
    }

    private func onSaveButtonTapped() {
        switch viewMode {
        case .create:
            modelContext.insert(item)
            dismiss()
        case .edit:
            try? modelContext.save()
            viewMode = .read

        default:
            fatalError("Unsupported operation for view mode: '\(viewMode)'")
        }
    }

    private func onEditButtonTapped() {
        viewMode = .edit
    }
}

// MARK: - Preview -

#Preview {
    NavigationView {
        ItemDetailView(initialState: .edit(.init(title: "f", summary: "S")))
    }
}
