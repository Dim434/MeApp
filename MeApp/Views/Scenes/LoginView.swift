//
//  ContentView.swift
//  MeApp
//
//  Created by Dmitry on 12/8/22.
//

import SwiftUI
import PhotosUI
import NIO
struct LoginView: View {
    @EnvironmentObject var model: MeModel {
        didSet {
            textFieldString = model.username ?? ""
            ipFieldString = model.ip ?? ""
            portFieldString = "\(model.port ?? 0)"
        }
    }
    @State private var textFieldString: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var ipFieldString: String = ""
    @State private var portFieldString: String = ""
    @State private var errorText: String? = nil {
        didSet {
            if errorText != nil {
                errorIsPresented = true
            } else {
                errorIsPresented = false
            }
        }
    }
    @State private var errorIsPresented = false
    var body: some View {
        
        VStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    Image(uiImage: model.image)
                        .resizable()
                        .frame(width: 128, height: 128)
                        .clipShape(Circle())
                }
            HStack{
                TextField("Username", text: $textFieldString, prompt: Text("Username"), axis: .horizontal)
                    .padding()
                    .background(Color.blue)
                    .frame(width: 240)
                    .clipShape(Capsule())
                    .foregroundColor(Color.white)
            }
            HStack {
                TextField("IP", text: self.$ipFieldString, prompt: Text("IP"), axis: .horizontal)
                    .padding()
                    .background(Color.blue)
                    .frame(width: 240)
                    .clipShape(Capsule())
                    .foregroundColor(Color.white)
                TextField("Port", text: self.$portFieldString, prompt: Text("Port"), axis: .horizontal)
                    .padding()
                    .background(Color.blue)
                    .frame(width: 90)
                    .clipShape(Capsule())
                    .foregroundColor(Color.white)
                    .keyboardType(.numberPad)
            }
            Button("Login",
                   action: login)
            .buttonStyle(.borderedProminent)
            .padding()
            .clipShape(Capsule())
            .alert(isPresented: $errorIsPresented) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorText ?? ""),
                    dismissButton: .cancel(Text("OK"))
                )
            }
            
        }
        .padding()
        .onChange(of: selectedItem) { item in
            item?.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let image):
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        self.model.image = UIImage(data: image) ?? UIImage()
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
        
        .onAppear {
            textFieldString = self.model.username ?? ""
            ipFieldString = self.model.ip ?? ""
            portFieldString = "\(self.model.port ?? 0)"
        }
    }
    func login() {
        if (ipFieldString != ""
            && portFieldString != ""
            && textFieldString != ""
            && Int(portFieldString) != nil
        ) {
            self.model.ip = ipFieldString
            self.model.port = Int(portFieldString) ?? 0
            self.model.username = textFieldString
            self.model.currentUser?.userName = textFieldString
            //            MeModel.currentUser.avatar = self.model.image
            DispatchQueue.global(qos: .background).async {
                switch  ChatRoom.connect(
                    with: self.model.ip!,
                    port: self.model.port!,
                    bind: self.model,
                    completion: { data in
                        DispatchQueue.main.async {
                            guard let user = try? JSONDecoder().decode(Message.self, from: data) else { return }
                            self.model.messages.append(user)
                            if self.model.status != .dontTouch {
                                let systemSoundID: SystemSoundID = 1016
                                try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                                AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil)
                                AudioServicesPlayAlertSoundWithCompletion(systemSoundID, nil)
                            }
                        }
                    }) {
                case .success(let room):
                    DispatchQueue.main.async {
                        self.model.room = room
                        self.model.currentUser!.ip = ChatRoom.getIpAddress() ?? "127.0.0.1"
                        self.model.router.push(.chat)
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.errorText = err.localizedDescription
                    }
                }
            }
        } else {
            self.errorText = "Not all fields are filled"
        }
    }
}
