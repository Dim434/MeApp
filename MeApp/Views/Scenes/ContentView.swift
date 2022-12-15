//
//  ContentView.swift
//  MeApp
//
//  Created by Dmitry on 12/9/22.
//

import Foundation
import SwiftUI
struct ContentView: View {
    @EnvironmentObject var model: MeModel

    var body: some View {
        VStack {
            LoginView()
                .environmentObject(model)
        }
    }
}
