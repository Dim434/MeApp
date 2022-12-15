//
//  XMLImporterView.swift
//  MeApp
//
//  Created by Dmitry on 12/14/22.
//

import Foundation
import SwiftUI
import XMLCoder
import Crypto

struct XMLImporterView: View {
    @Environment(\.presentationMode) var presentationMode
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
                self.isPresented = true
            } label: {
                Text("Import")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .clipShape(Capsule())
        }
        .fileImporter(isPresented: $isPresented,
                      allowedContentTypes: [.xml]
        ) { result in
            switch result {
            case .success(let url):
                importDocument(password: self.password, data: (try? Data(contentsOf: url)) ?? Data())
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    func importDocument(password: String = "", data: Data) {
        var openData: Data = data
        if password != "" {
            openData = (try? aesCBCDecrypt(data: data, keyData: password.data(using: .utf8)!)) ?? Data()
        }
        let decoder = XMLDecoder()
        guard let unsealedData = try? decoder.decode([Message].self, from: openData) else { return }
        self.model.messages = unsealedData
        self.model.router.pop()
    }
}

struct XMLExportView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MeModel()
        return XMLExporterView()
            .environmentObject(model)
    }
}

