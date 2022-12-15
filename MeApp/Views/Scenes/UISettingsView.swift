//
//  UISettingsView.swift
//  MeApp
//
//  Created by Dmitry on 12/14/22.
//

import Foundation
import SwiftUI
struct UISettingsView: View {
    var model: MeModel
    @State var color: Color
    @State var backgroundColor: Color
    @State var isIp: Bool
    @State var isDate: Bool
    init(model: MeModel) {
        self.model = model
        self._color = State(initialValue: model.messageColor)
        self._backgroundColor = State(initialValue: model.backgroundColor)
        self._isIp = State(initialValue: model.isIpVisible)
        self._isDate = State(initialValue: model.isDate)
    }
    var body: some View {
        VStack {
            ColorPicker("MessageColor", selection: $color)
                .padding()
            ColorPicker("BackgroundColor", selection: $backgroundColor)
                .padding()
            Toggle("Is IP Visible", isOn: $isIp)
                .padding()
            Toggle("Is Date Visible", isOn: $isDate)
                .padding()
            Button {
                self.model.messageColor = color
                self.model.isIpVisible = isIp
                self.model.backgroundColor = backgroundColor
                self.model.isDate = isDate
                self.model.router.pop()
            } label: {
                Text("Save")
            }
            .padding()
        }
        .frame(maxWidth: 300)
        .padding()
    }
}
