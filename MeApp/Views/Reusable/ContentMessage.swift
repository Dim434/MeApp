//
//  ContentMessage.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation
import SwiftUI
struct ContentMessageView: View {
    var contentMessage: MessageType
    var date: Date
    var isDate: Bool
    var isCurrentUser: Bool
    var color: Color
    @State var isPresented = false
    var body: some View {
        HStack {
            if case let .msg(string) = contentMessage {
                Text(string)
                    .padding(10)
                    .foregroundColor(isCurrentUser ? Color.white : Color.black)

                    .cornerRadius(10)
                
            }
            if case let .file(name, contents) = contentMessage {
                Button {
                    print("tapped")
                    self.isPresented = true
                } label: {
                    VStack {
                        Image(uiImage: .fileImage)
                            .resizable()
                            .frame(width: 64, height: 64)
                        Text(name)
                            .padding()
                            .foregroundColor(isCurrentUser ? Color.white : Color.black)
                    }
                    .cornerRadius(10)
                }
                .fileExporter(
                    isPresented: $isPresented,
                    document: MessageDocument(message: contents),
                    contentType: .data,
                    defaultFilename: name
                ) { result in
                    switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    self.isPresented = false
                }.onTapGesture {
                    self.isPresented = true
                }
            }
            if case let .image(contents) = contentMessage {
                VStack {
                    Image(uiImage: contents)
                        .resizable()
                        .frame(width: 128, height: 128)
                }
                .cornerRadius(10)
            }
            if isDate {
                VStack() {
                    Spacer()
                    Text(date, style: .time)
                        .font(.system(size: 10))
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 4))
            }
        }
        .background(isCurrentUser ? color : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
        .cornerRadius(10)
        
    }
}

struct ContentMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
//            ContentMessageView(contentMessage: .msg("Hi, I am your friend"), isCurrentUser: false)
//            ContentMessageView(contentMessage: .file("name_of_file.str", Data()), isCurrentUser: false)
//            ContentMessageView(contentMessage: .image(.defaultAvatar), isCurrentUser: false)
        }
    }
}
