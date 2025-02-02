//
//  CameraPreview.swift
//  DealifyApp
//
//  Created by Nathan Audegond on 02/02/2025.
//

// CameraPreview.swift
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        camera.session.startRunning()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
