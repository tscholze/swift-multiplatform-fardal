//
//  CameraPicker.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import AVFoundation

/// Represents a modal camera live-feeded photo
/// picker.
///
/// Listen to the `cameraImagesData` for new image `Data`.
struct CameraPicker: View {
    // MARK: - Properties -

    /// Contains user approved images that shall be consumed by
    /// caller.
    @Binding var cameraImagesData: [ImageModel]

    // MARK: - Private properties -

    @ObservedObject private var cameraModel = CameraModel()
    @State private var takenImagesData = [ImageModel]()
    @State private var flashOpacity = 0.0
    @Environment(\.dismiss) private var dismiss

    // MARK: - View -

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.none) {
            HStack {
                Button("Misc.Cancel") { dismiss() }
                Spacer()
                Button(cameraModel.flashMode.localizedName) { cameraModel.toggleFlash()
                }
                Spacer()
                Button("CameraPicker.Action.Submit") {
                    cameraImagesData = takenImagesData
                    dismiss()
                }
            }
            .padding()
               
            makeCameraPreview()
            makeShutterButton()
            makeBottomContainer()
        }
        .background(Color.black)
        .navigationTitle("CameraPicker.Title")
        .task { try? await cameraModel.initialize() }
    }
}

// MARK: - View Builder -

extension CameraPicker {
    @ViewBuilder
    private func makeCameraPreview() -> some View {
        // Live feed
        // If simulator show warning
        // Else show Camera Preview
        if UIDevice.isSimulator {
            Rectangle()
                .foregroundColor(.gray)
                .overlay {
                    Text("CameraPicker.SimulatorNotSupported.Hint")
                }
        }
        else {
            CameraPreview(cameraModel: cameraModel)
                .onChange(of: cameraModel.takenImageData) { _, newValue in
                    guard let newValue else { return }
                    takenImagesData.append(newValue)
                }
                .overlay { Color.white.opacity(flashOpacity) }
        }
    }

    @ViewBuilder
    private func makeShutterButton() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("CameraPicker.Section.TakenImages")
                Group {
                    if let imageData = takenImagesData.last {
                        List(imageData.tags) { tag in
                            LabeledContent(tag.title, value: tag.mlConfidence, format: .percent)
                        }
                    } else {
                        Text("CameraPicker.Section.TakenImages.Empty.Hint")
                    }
                }
                .font(.caption)
                
                Spacer()
            }
            .frame(height: 60)
            .foregroundStyle(.white)
            
            Spacer()
            // Button
            Button("") {
                flashOpacity = 1
                cameraModel.takePicture()
                withAnimation(.easeIn(duration: 1)) {
                    flashOpacity = 0
                }
            }
            .buttonStyle(ShutterButton())
            .disabled(UIDevice.isSimulator || flashOpacity != 0.0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    private func makeBottomContainer() -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            // Title
            Text("CameraPicker.TakenPhotos.Headline")
                .font(.headline)
                .foregroundColor(.white)

            HStack(alignment: .center) {
                // List of taken photos
                makeTakenPhotosList()

                // Spacer to move the button to the right
                Spacer()

                // Simulator mock button.
                if UIDevice.isSimulator {
                    Button("CameraPicker.Actions.Mock") {
                        takenImagesData.append(
                            .init(data: MockGenerator.makeMockSquareSymbol())
                        )
                    }
                    .tint(Color.pink)
                }
            }
            .background(Material.ultraThin.opacity(0.2))
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func makeTakenPhotosList() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.medium) {
                if takenImagesData.isEmpty {
                    Image(systemName: "photo")
                        .resizable()
                        .foregroundStyle(.white)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .opacity(0.2)
                } else {
                    ForEach(Array(takenImagesData.enumerated()), id: \.offset) { index, model in
                        Button(action: { takenImagesData.remove(at: index) }) {
                            ZStack(alignment: .topTrailing) {
                                model.image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                
                                Image(systemName: "xmark.circle.fill")
                                    .tint(Color.white)
                                    .shadow(radius: Theme.Shadow.radius1)
                                    .padding(4)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 80)
    }
}

// MARK: - Button styles -

extension CameraPicker {
    /// Style for a photo taking shutter button.
    private struct ShutterButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .frame(width: 60, height: 60)
                .padding()
                .foregroundColor(.accentColor)
                .background(configuration.isPressed ? Color.orange : Color.red)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: Theme.Shadow.radius1)
        }
    }
}

// MARK: - Preview -

#Preview {
    @State var imagesData = [ImageModel]()
    return CameraPicker(cameraImagesData: $imagesData)
}
