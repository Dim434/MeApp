//
//  MeAppApp.swift
//  MeApp
//
//  Created by Dmitry on 12/8/22.
//

import SwiftUI

@main
struct MeApp: App {
    @StateObject var model = MeModel().load()
    
    var body: some Scene {
        WindowGroup {
            RouterView(router: model.router) { path in
                switch path {
                case .login: ContentView().environmentObject(self.model)
                case .chat: ChatView().environmentObject(self.model)
                case .settings(let type): SettingsView(type: type).environmentObject(self.model)
                case .xmlImporter: XMLImporterView().environmentObject(self.model)
                case .uiSettings: UISettingsView(model: self.model).environmentObject(self.model)
                case .imagePreview(let image): ImagePreviewView(image: image).environmentObject(self.model)
                case .xmlExporter: XMLExporterView().environmentObject(self.model)
                }
            }
        }
    }
}
