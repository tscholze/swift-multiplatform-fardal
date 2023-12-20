//
//  CameraPreviewView.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import SwiftUI
import Foundation
import AVFoundation

/// SwiftUI wtapper for the sadly `UIKit` based `PreviewLayerView`.
/// The `cameraModel` is required to be set.
struct CameraPreview: UIViewRepresentable {
    // MARK: - Internal properties -

    let cameraModel: CameraModel

    // MARK: - UIViewRepresentable -

    func makeUIView(context _: Context) -> UIView {
        return PreviewLayerView(previewLayer: cameraModel.previewLayer)
    }

    func updateUIView(_: UIViewType, context _: Context) {}
}

// MARK: - PreviewLayerView -

private class PreviewLayerView: UIView {
    // MARK: - Private properties -

    private let previewLayer: AVCaptureVideoPreviewLayer

    // MARK: - Init -

    init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        super.init(frame: .zero)
        backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill

        layer.addSublayer(previewLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overwrittens -

    override func layoutSublayers(of layer: CALayer) {
        guard layer == self.layer else { return }
        previewLayer.frame = .init(
            x: 0,
            y: layer.bounds.height / 2 - layer.bounds.width / 2,
            width: layer.bounds.width,
            height: layer.bounds.width
        )
    }
}
