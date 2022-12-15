//
//  SettingsView.swift
//  MeApp
//
//  Created by Dmitry on 12/14/22.
//

import Foundation
import SwiftUI
import PhotosUI

enum SettingsType {
    case user
    case network
}
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var type: SettingsType
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
            if type == .user {
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
                    TextField("Username", text: $textFieldString, prompt: Text("Username"), axis: .horizontal)
                        .padding()
                        .background(Color.blue)
                        .frame(width: 240)
                        .clipShape(Capsule())
                        .foregroundColor(Color.white)
                    
                }
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
            } else  {
                VStack {
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
            }
            Button(self.type == .user ? "Save" : "Reconnect",
                   action: action)
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
        .onAppear {
            self.ipFieldString = self.model.ip ?? ""
            self.portFieldString = "\(self.model.port ?? 45678)"
            self.textFieldString = self.model.username ?? ""
        }
    }
    func action() {
        if type == .user {
            save()
        } else {
            login()
        }
    }
    func save() {
        self.model.username = textFieldString
        self.presentationMode.wrappedValue.dismiss()
    }
    func login() {
        if (ipFieldString != ""
            && Int(portFieldString) != nil
        ) {
            self.model.room?.group.shutdownGracefully { err in
                
                self.model.ip = ipFieldString
                self.model.port = Int(portFieldString) ?? 0
                //            MeModel.currentUser.avatar = self.model.imag
                DispatchQueue.global(qos: .background).async {
                    switch  ChatRoom.connect(
                        with: self.model.ip!,
                        port: self.model.port!,
                        bind: self.model,
                        completion: { data in
                            DispatchQueue.main.async {
                                guard let user = try? JSONDecoder().decode(Message.self, from: data) else { return }
                                self.model.messages.append(user)
                            }
                        }) {
                    case .success(let room):
                        DispatchQueue.main.async {
                            self.model.room = room
                            self.model.currentUser!.ip = ChatRoom.getIpAddress() ?? "127.0.0.1"
                            self.model.router.pop()
                        }
                    case .failure(let err):
                        DispatchQueue.main.async {
                            self.errorText = err.localizedDescription
                        }
                    }
                }
            }
        } else {
            self.errorText = "Not all fields are filled"
        }
    }
}


