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
            
            DispatchQueue.global(qos: .background).async {
               self.session.startRunning()
           }
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
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken = false
                    self.isSaved = false
                    self.picData = Data()
                }
            }
        }
    }
    
    func savePic() {
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isSaved = true
        uploadPic(image: image) {[weak self] groceryItems in
            DispatchQueue.main.async {
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
        
        // Convert UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        var body = Data()

        // Append form-data boundary
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)

        let fileName = "image.jpg"
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        
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
    

