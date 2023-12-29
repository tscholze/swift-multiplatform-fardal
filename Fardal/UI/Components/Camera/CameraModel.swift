//
//  CameraModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

/// Wraps an `AVFoundation` based `AVCaptureSession` as a
/// configurable and observable model.
class CameraModel: NSObject, ObservableObject {
    // MARK: - Internal properties -

    /// Taken image data
    @Published
    private(set) var takenImageData: ImageModel?
    
    @Published
    private(set) var flashMode = AVCaptureDevice.FlashMode.auto

    /// Preview layer that can be used to show a live feed of the camera finder.
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)

    // MARK: - Private helper -

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let classifier: MobileNetV2
    private var cameraSettings = AVCapturePhotoSettings()
    
    // MARK: - Init -
    
    override init() {
        guard let mobileNet = try? MobileNetV2(configuration: .init()) else {
            fatalError("Init of ML model failed")
        }
        
        classifier = mobileNet
        
        super.init()
    }
    
    // MARK: - Internal helper -

    /// Initializes a new `CameraModel`
    /// Must be called before usage.
    func initialize() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted: throw CameraError.noPermissionGranted
        case .authorized: try setup()
        case .notDetermined: try await requestPermission()
        @unknown default: throw CameraError.unknown
        }
    }

    /// Takes the actual picture.
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        Task { output.capturePhoto(with: settings, delegate: self) }
    }
    
    /// Toggles the flash
    func toggleFlash() {
        flashMode = AVCaptureDevice.FlashMode(rawValue: (flashMode.rawValue + 1) % 3) ?? .off
    }

    // MARK: - Private helper -

    private func setup() throws {
        do {
            // Start configuration
            session.beginConfiguration()

            // Get (camera) device
            let device = AVCaptureDevice.default(
                .builtInDualCamera,
                for: .video, position: .back
            )

            // Ensure a camera was found
            guard let device else {
                throw CameraError.deviceNotfound
            }

            // Get input from device
            let input = try AVCaptureDeviceInput(device: device)
            
            // Check if it possible to add input (reader aka camera) to session
            if session.canAddInput(input) {
                session.addInput(input)
            }
            else {
                throw CameraError.invalidSession
            }

            // Check if it possible to add outout to session
            if session.canAddOutput(output) {
                session.sessionPreset = .medium
                session.addOutput(output)
            }
            else {
                throw CameraError.invalidSession
            }

            // Commit configiguration
            session.commitConfiguration()

            // and start running
            session.startRunning()
        }
        catch {
            // Throw an error if operation failed setting up
            // the camera
            throw CameraError.deviceNotfound
        }
    }

    private func requestPermission() async throws {
        // Ask user for permission
        // if user give permission setup
        if await AVCaptureDevice.requestAccess(for: .video) {
            try setup()
        }
        else {
            throw CameraError.noPermissionGranted
        }
    }
    
    private func classifyImage(_ image: UIImage, maxLength: Int = 5) -> [Classification] {
        
        guard let resizedImage = image.resizeImageTo(size:CGSize(width: 224, height: 224)),
              let buffer = resizedImage.convertToBuffer() else {
            print("Cannot resize image")
            return []
        }
        
        guard let output = try? classifier.prediction(image: buffer) else {
            print("Cannot create out from prediction using buffer")
            return []
        }
        
        let results: [Classification] = output.classLabelProbs
            .sorted { $0.1 > $1.1 }
            .map { .init(confidence: $1, value: $0) }
        
        return Array(results.prefix(maxLength))
    }
    
    // MARK: - Deinit -

    deinit {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    // MARK: - Camera error -

    /// Describes all available error that can occure
    /// during camera usage
    enum CameraError: Error {
        case noPermissionGranted
        case invalidSession
        case deviceNotfound
        case unknown
    }
}

// MARK: - AVCapturePhotoCaptureDelegate -

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        // 1. Check for error
        // 2. Create data from captured photo.
        guard error == nil, let data = photo.fileDataRepresentation() else {
            print("Cannot create data from image")
            return
        }
        
        // 3. Check if a CGImage is possible
        guard let cgImage = photo.cgImageRepresentation() else {
            print("Cannot create cgImage from photo")
            return
        }
        
        // 4. Classify image
        let tags = classifyImage(.init(cgImage: cgImage))
        print(tags.map{ $0.formatted}.joined(separator: "\n"))
        
        // Return generated meep
        Task {
            await MainActor.run {
                takenImageData = .init(
                    data: data,
                    source: .photo,
                    tags: tags.map { $0.value }
                )
            }
        }
    }
}

// MARK: - MLCore -

extension CameraModel {
    private static func makeImageClassifier() -> VNCoreMLModel {
        // Create an instance of the image classifier's wrapper class.
        guard let imageClassifier = try? MobileNetV2(configuration: .init()) else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model


        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }


        return imageClassifierVisionModel
    }
}

extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
     func convertToBuffer() -> CVPixelBuffer? {
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }

}


fileprivate struct Classification {
    let confidence: Double
    let value: String
    
    var formatted: String {
        return "\(value): \(confidence * 100)%"
    }
}


extension AVCaptureDevice.FlashMode {
    var localizedName: String {
        switch self {
        case .off:
            NSLocalizedString("AVCaptureDevice.FlashMode.Off", comment: "")
        case .on:
            NSLocalizedString("AVCaptureDevice.FlashMode.On", comment: "")
        case .auto:
            NSLocalizedString("AVCaptureDevice.FlashMode.Auto", comment: "")
        @unknown default:
            "X"
        }
    }
}
