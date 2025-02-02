//
//  CameraView.swift
//  DealifyApp
//
//  Created by Nathan Audegond on 02/02/2025.
//

// CameraView.swift
import SwiftUI

struct CameraView: View {
    @StateObject var camera = CameraModel()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: StoreLocationViewModel 
    
    var body: some View {
        ZStack {
            if camera.isTaken, let uiImage = UIImage(data: camera.picData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            } else {
                CameraPreview(camera: camera)
                    .ignoresSafeArea()
            }
            VStack {
                // Top bar with close button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    Spacer()
                }
                
                Spacer()
                
                // Camera controls
                HStack {
                    if camera.isTaken {
                        // Retake and save buttons
                        Button(action: camera.retake) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            camera.savePic()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    } else {
                        // Shutter button
                        Button(action: camera.takePic) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            camera.check()
            camera.uploadCompletion = { groceryItems in
                viewModel.groceryItems = groceryItems
                presentationMode.wrappedValue.dismiss()
            }}
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Please enable camera access"))
        }
    }
}
