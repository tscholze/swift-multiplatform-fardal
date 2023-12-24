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

    private var item: ItemModel?
    private let intialViewMode: ViewMode

    @State private var viewMode: ViewMode = .read
    @State private var title = ""
    @State private var summary = ""
    @State private var collection: CollectionModel? = nil
    @State private var showAddCollectionAlert = false
    @State private var showAddCollectionSheet = false
    @State private var showLinkCollectionSheet = false
    @State private var showAddCustomAttributeSheet = false
    @State private var showAddMediaSheet = false
    @State private var showIconWizard = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedColor: Color = Color.white
    @State private var chips: [ChipModel] = []
    @State private var imagesData = [ImageData]()
    @State private var imageSelection: PhotosPickerItem? = nil
    @State private var customAttributes = [ItemCustomAttribute]()
    @State private var cameraImagesData = [Data]()
    @State private var iconData: Data? = nil
    @State private var cameraModel = CameraModel()
    @State private var isValid = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var collections: [CollectionModel]

    // MARK: - Init -

    /// Initializes a new detail view with given state configuration
    ///
    /// - Parameter initialState: Initial state that defines the viewMode and the datasource.
    init(initialState: ItemDetailViewInitalState) {
        switch initialState {
        case let .read(item):
            self.item = item
            intialViewMode = .read

        case .create:
            item = nil
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
        .alert("Item.Draft.Detail.Action.AddCollection", isPresented: $showAddCollectionAlert) {
            makeAddCollectionAlertContent()
        }
        .sheet(isPresented: $showAddCollectionSheet) {
            NavigationView {
                CollectionDetailView(initialState: .create)
            }
        }
        .sheet(isPresented: $showLinkCollectionSheet) {
            ItemDetailLinkCollectionView(selectedCollection: $collection)
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
    private func makeCollectionSection() -> some View {
        Section {
            if let collection {
                NavigationLink {
                    CollectionDetailView(initialState: .read(collection))
                } label: {
                    HStack {
                        collection.coverImageData.image
                            .resizable()
                            .clipShape(Theme.Shape.roundedRectangle2)
                            .frame(width: 60, height: 60)

                        VStack {
                            Text(collection.title)
                            Text(collection.summary)
                        }
                    }
                }
            }
            else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)

                    Text("Item.Draft.Detail.Section.Collection.Empty.Hint")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
                .opacity(0.6)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            HStack {
                Text("Item.Draft.Detail.Section.Collection.Title")
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
        Section("Item.Draft.Detail.Section.Tagging.Title") {
            // Color
            HStack(alignment: .center) {
                Text("Item.Draft.Detail.Section.Tagging.Flag")

                // Identicator
                Image(systemName: "flag.square.fill")
                    .foregroundStyle(selectedColor)

                // Color picker button if is in edit mode
                if viewMode != .read {
                    // Picker
                    ColorPicker("", selection: $selectedColor)
                }
            }

            VStack(alignment: .leading) {
                Text("Item.Draft.Detail.Section.Tagging.Tag")
                ChipsView(chips: $chips, viewMode: $viewMode)
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
                                .clipShape(Theme.Shape.roundedRectangle2)
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
                Text("Item.Draft.Detail.Section.Photos.Title \(imagesData.count) / \(FardalConstants.Item.maxNumberOfPhotosPerItem)")
                if viewMode != .read {
                    HStack {
                        Spacer()
                        Button {
                            showAddMediaSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                        }.disabled(imagesData.count == FardalConstants.Item.maxNumberOfPhotosPerItem)
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
    }

    @ViewBuilder
    private func makeEmptyImagesHint() -> some View {
        HStack(spacing: 24) {
            Hint(
                titleKey: "Item.Draft.Detail.Section.Photo.Empty.Camera.Hint",
                systemName: "camera.viewfinder"
            )

            Divider()

            Hint(
                titleKey: "Item.Draft.Detail.Section.Photo.Empty.Icon.Hint",
                systemName: "rectangle.center.inset.filled.badge.plus"
            )

            Divider()

            Hint(
                titleKey: "Item.Draft.Detail.Section.Photo.Empty.Library.Hint",
                systemName: "photo.badge.plus"
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
                if customAttributes.isEmpty {
                    makeEmptyCustomAttributeHint()
                }
                else {
                    List {
                        ForEach(customAttributes) { attribute in
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
            Hint(
                titleKey: "Item.Draft.Detail.Section.CustomAttributes.Empty.Pricing.Hint",
                systemName: "eurosign.circle"
            )

            Divider()

            Hint(
                titleKey: "Item.Draft.Detail.Section.CustomAttributes.Empty.Dates.Hint",
                systemName: "calendar"
            )

            Divider()

            Hint(
                titleKey: "Item.Draft.Detail.Section.CustomAttributes.Empty.Url.Hint",
                systemName: "safari"
            )

            Divider()

            Hint(
                titleKey: "Item.Draft.Detail.Section.CustomAttributes.Empty.More.Hint",
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
            if let item {
                HStack {
                    Spacer()
                    Button("Item.Draft.Detail.Actions.DeleteItem", role: .destructive) {
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

    @ViewBuilder
    private func makeAddCollectionAlertContent() -> some View {
        // Photo picker
        Button("Item.Draft.Action.CreateCollection") {
            showAddCollectionSheet.toggle()
        }

        // Camera
        Button("Item.Draft.Action.AssignCollection") {
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
                    Text("Item.Draft.Action.Edit")
                }
            }
        }
        else {
            // Cancel button
            if viewMode != .create {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { onCancelTapped() }) {
                        Text("Item.Draft.Action.Cancel")
                    }
                }
            }

            // Save button
            ToolbarItem(placement: .primaryAction) {
                Button(
                    "Item.Draft.Action.Save",
                    action: onSaveButtonTapped
                )
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
        populateViewWithItemInformation()
    }

    private func onTitleChanged(oldValue _: String, newValue _: String) {
        isValid = isValidInput()
    }

    private func onSummaryChanged(oldValue _: String, newValue _: String) {
        isValid = isValidInput()
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
        if item != nil {
            populateViewWithItemInformation()
            viewMode = .read
        }
        else {
            dismiss()
        }
    }

    private func populateViewWithItemInformation() {
        title = item?.title ?? ""
        summary = item?.summary ?? ""
        chips = item?.tags.map { ChipModel(title: $0) } ?? []
        selectedColor = Color(hex: item?.hexColor ?? 0xFFFFFF)
        imagesData = item?.imagesData ?? []
        isValid = isValidInput()
        collection = item?.collection
    }

    private func onAddCollectionTapped() {
        showAddCollectionAlert.toggle()
    }

    private func onAddIconTapped() {
        showIconWizard.toggle()
    }

    private func onAddCustomTapped() {
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddPriceCustomAttributeTapped() {
        customAttributes.append(.emptyPriceAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddDateCustomAttributeTapped() {
        customAttributes.append(.emptyDateAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddUrlCustomAttributeTapped() {
        customAttributes.append(.emptyUrlAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onAddNoteCustomAttributeTapped() {
        customAttributes.append(.emptyNoteAttribute)
        showAddCustomAttributeSheet.toggle()
    }

    private func onDeleteCustomTapped(withIndexSet indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let attribute = customAttributes[index]
        customAttributes.removeAll(where: { $0.id == attribute.id })
    }

    private func onSaveButtonTapped() {
        if let item {
            // Remove attributes from database which are deleted in drafts
            item.customAttributes.forEach { itemAttribute in
                if customAttributes.contains(itemAttribute) == false {
                    modelContext.delete(itemAttribute)
                }
            }

            // TODO: Check if this is also needed for imagesData

            item.title = title
            item.summary = summary
            item.customAttributes = customAttributes
            item.hexColor = selectedColor.hexValue
            item.tags = chips.map(\.title)
            item.imagesData = imagesData
            item.updatedAt = .now
            viewMode = .read
        }
        else {
            let newItem = ItemModel(
                title: title,
                summary: summary,
                hexColor: selectedColor.hexValue,
                imagesData: imagesData,
                customAttributes: customAttributes,
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
