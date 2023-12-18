//
//  CameraModel.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import Foundation
import AVFoundation

class CameraModel: NSObject, ObservableObject {
    // MARK: - Internal properties -

    @Published private(set) var takenImageData: Data?
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)

    // MARK: - Private helper -

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    // MARK: - Internal helper -

    func initialize() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted: throw CameraError.noPermissionGranted
        case .authorized: try setup()
        case .notDetermined: try await requestPermission()
        @unknown default: throw CameraError.unknown
        }
    }

    func takePicture() {
        Task { output.capturePhoto(with: .init(), delegate: self) }
    }

    // MARK: - Private helper -

    private func setup() throws {
        do {
            defer {
                session.commitConfiguration()
            }

            // Start configuration
            session.beginConfiguration()

            // Get (camera) device
            let device = AVCaptureDevice.default(
                .builtInDualCamera,
                for: .video, position: .back
            )
            
            // Ensure a camera was found
            guard let device = device else {
                throw CameraError.deviceNotfound
            }

            // Get input from device
            let input = try AVCaptureDeviceInput(device: device)

            // Check if it possible to add input (reader aka camera) to session
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                throw CameraError.invalidSession
            }

            // Check if it possible to add outout to session
            if session.canAddOutput(output) {
                session.addOutput(output)
            } else {
                throw CameraError.invalidSession
            }
            
            // Autostart running
            session.startRunning()
        } catch {
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

    // MARK: - Deinit -

    deinit {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    // MARK: - Camera error -

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
        guard error == nil, let data = photo.fileDataRepresentation() else { return }
        Task { await MainActor.run { takenImageData = data } }
    }
}
