//
//  XMLView.swift
//  MeApp
//
//  Created by Dmitry on 12/13/22.
//

import Foundation
import SwiftUI
import XMLCoder
import Crypto

struct XMLExporterView: View {
    @EnvironmentObject var model: MeModel
    @State var password: String = ""
    @State var isPresented = false
    @State var document: MessageDocument = MessageDocument(message: Data())
    var body: some View {
        VStack {
            Text("Use 16,24 or 32 symbols")
            SecureInputView("Password", text: $password)
                .frame(width: 240)
            Button {
                self.document = exportDocument(password: password)
                isPresented = true
            } label: {
                Text("Export")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .clipShape(Capsule())
        }
        .fileExporter(
            isPresented: $isPresented,
            document: document,
            contentType: .xml,
            defaultFilename: "history.xml"
        ) { result in
            print(result)
        }
    }
    func exportDocument(password: String = "") -> MessageDocument {
        defer {
            self.model.router.pop()
        }
        print(password)
        let encoder = XMLEncoder()
        var data = try! encoder.encode(self.model.messages, withRootKey: "history")
        if password != "" {
            let sealedData =  (try? aesCBCEncrypt(data: data, keyData: password.data(using: .utf8)!))
            data = sealedData ?? data
        }
        return MessageDocument(message: data)
    }
}

struct XMLView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MeModel()
        return XMLExporterView()
            .environmentObject(model)
    }
}

