// CameraModel.swift
import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CameraModel: NSObject, ObservableObject {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    var uploadCompletion: (([GroceryItem]) -> Void)?
    
    func check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        do {
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
            }
        }
    }
    
    func retake() {
        DispatchQueue.main.async {
            self.session.stopRunning()
            self.isTaken = false
            self.isSaved = false
            self.picData = Data()
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
    
    func savePic() {
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isSaved = true
        uploadPic(image: image) {[weak self] groceryItems in
            DispatchQueue.main.async {
                // Call the completion handler if it exists
                self?.uploadCompletion?(groceryItems)
            }
        }
    }
    
    func uploadPic(image: UIImage,completion: @escaping ([GroceryItem]) -> Void) {
        guard let url = URL(string: "https://dealify-n5sl.onrender.com/items/image") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // ... rest of your upload code remains the same ...
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    if let data = data {
                        do {
                            // Decode the response into GroceryItem array
                            let decoder = JSONDecoder()
                            let groceryItems = try decoder.decode([GroceryItem].self, from: data)
                            
                            // Update the UI on the main thread
                            DispatchQueue.main.async {
                                completion(groceryItems)
                            }
                        } catch {
                            print("Failed to decode response: \(error)")
                        }
                    }
                } else {
                    print("Upload failed with status: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
    }
}
    
    extension CameraModel: AVCapturePhotoCaptureDelegate {
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let imageData = photo.fileDataRepresentation() else { return }
            DispatchQueue.main.async {
                self.picData = imageData
                self.isTaken = true
                self.session.stopRunning()
            }
        }
    }
    

