//
//  ChatView.swift
//  MeApp
//
//  Created by Dmitry on 12/9/22.
//

import Foundation
import SwiftUI
struct ChatView: View {
    @State var typingMessage: String = ""
    @EnvironmentObject var model: MeModel
    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var isExporting = false
    @State private var selected = -1
    @State var shownImage: UIImage = UIImage()
    @State var isImporting = true
    var body: some View {
        VStack {
            List(self.model.messages) { msg in
                if let msg = msg as Message {
                    MessageView(currentMessage: msg.messageType, date: msg.time, isDate: model.isDate, user: msg.user, color: model.messageColor, isIp: model.isIpVisible)
                        .listRowBackground(EmptyView())
                        .listRowSeparator(.hidden)
                        .frame(alignment: .leading)
                        .listRowInsets(.none)
                        .onTapGesture {
                            if case let .image(image) = msg.messageType  {
                                shownImage = image
                                self.model.router.push(.imagePreview(image))
                            }
                        }
                }
               
            }
            .background(model.backgroundColor)
            .listRowSeparator(.hidden)
            HStack {
                if typingMessage == "" {
                    Button {
                        isExporting = true
                    } label: {
                        Image(systemName: "paperclip")
                    }
                }
                TextField("Message...", text: $typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                    .scrollDismissesKeyboard(.immediately)
                    
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
            .frame(minHeight: CGFloat(50))
            .padding()
        }
        .background(model.backgroundColor)
        .padding(.bottom, keyboard.currentHeight)
        .edgesIgnoringSafeArea(keyboard.currentHeight == 0.0 ? .leading: .bottom)
        .toolbar {
            Menu {
                Button{
                    self.model.status = .standart
                } label: {
                    Label(MeModel.Status.standart.info, systemImage: MeModel.Status.standart.image)
                }
                Button{
                    self.model.status = .afk
                } label: {
                    Label(MeModel.Status.afk.info, systemImage: MeModel.Status.afk.image)
                }
                Button{
                    self.model.status = .dontTouch
                } label: {
                    Label(MeModel.Status.dontTouch.info, systemImage: MeModel.Status.dontTouch.image)
                }
            } label: {
                Image(systemName: self.model.status.image)
            }
            Button("", action: {})
                .background(self.model.isConnected ? .green : .red)
                .frame(width: 16, height: 16)
                .clipShape(Circle())
            Menu {
                Menu {
                    Button {
                        self.model.router.push(.settings(.user))
                    } label: {
                        Label("User", systemImage: "person")
                    }
                    Button {
                        self.model.router.push(.settings(.network))
                    } label: {
                        Label("Network", systemImage: "network")
                    }
                    Button {
                        self.model.router.push(.uiSettings)
                    } label: {
                        Label("UI", systemImage: "paintbrush.pointed")
                    }
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                Menu {
                    Button {
                        self.model.router.push(.xmlExporter)
                    } label: {
                        Label("Export XML", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        self.model.router.push(.xmlImporter)
                    } label: {
                        Label("Import XML", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Label("XML", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .fileImporter(isPresented: $isExporting, allowedContentTypes: [.image, .pdf, .wav, .archive]) { result in
            switch result {
            case .success(let success):
            guard let data = try? Data(contentsOf: success) else { return  }
                if success.mimeType().starts(with: "image") {
                    let msg =  Message(
                        user: self.model.currentUser!,
                        messageType: .image(UIImage(data: data) ?? UIImage())
                    )
                    self.model.messages.append(
                        msg
                    )
                    self.model.room?.sendMessage(msg: msg)
                } else {
                    let msg = Message(
                        user: self.model.currentUser!,
                        messageType: .file(success.lastPathComponent, data)
                    )
                    self.model.messages.append(
                        msg
                    )
                    self.model.room?.sendMessage(msg: msg)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        .onAppear {
            selected = -1
        }
        .navigationBarBackButtonHidden()
        .background(model.backgroundColor)
    }
    func sendMessage() {
        let msg = Message(
            user: self.model.currentUser!,
            messageType: .msg(typingMessage)
        )
        self.model.messages.append(
            msg
        )
        self.model.room?.sendMessage(msg: msg)
        typingMessage = ""
    }
}
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MeModel()
        model.messages.append(.init(user: .init(avatar: .defaultAvatar, userName: "ME", isCurrentUser: true), messageType: .msg("321")))
        model.messages.append(.init(user: .init(avatar: .defaultAvatar, userName: "ME", isCurrentUser: false), messageType: .msg("321")))
        return ChatView()
            .environmentObject(model)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
        
    }
}
