//
//  MessageView.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation
import SwiftUI
struct MessageView : View {
    var currentMessage: MessageType
    var date: Date
    var isDate: Bool
    var user: User
    var color: Color
    var isIp: Bool
    var body: some View {
            HStack(alignment: .bottom, spacing: 15) {
                if !user.isCurrentUser {
//                    Image(uiImage: user.avatar)
//                        .resizable()
//                        .frame(width: 64, height: 64)
//                        .clipShape(Circle())
//                        .padding()
                }
                VStack(alignment: .leading) {
                    Text(user.userName + (isIp ? " " + user.ip : ""))
                        .font(.system(size: 12))
                    ContentMessageView(contentMessage: currentMessage, date: date, isDate: isDate, isCurrentUser: user.isCurrentUser, color: color)
                }
            }
            .frame(
                width: 230,
                alignment: .leading
            )
    }
}

