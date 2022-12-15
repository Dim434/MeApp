//
//  Model.swift
//  MeApp
//
//  Created by Dmitry on 12/8/22.
//

import Foundation
import UIKit
import SwiftUI
public class MeModel: ObservableObject, Hashable {
    public enum Status:  CaseIterable {
        case standart
        case afk
        case dontTouch
        var info: String {
            switch self {
            case .standart: return "Online"
            case .afk: return "Away from Keyboard"
            case .dontTouch: return "Do not touch me"
            }
        }
        var image: String {
            switch self {
            case .standart: return "person"
            case .afk: return  "person.badge.clock"
            case .dontTouch: return "person.badge.minus"
            }
        }
    }
    public static func == (lhs: MeModel, rhs: MeModel) -> Bool {
        return lhs.username == rhs.username
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(username)
    }
    
    @KeychainStorage(key: "username", defaultValue: "") var username: String?
    @Published var image: UIImage = UIImage(named: "ic_empty_face") ?? UIImage()
    @KeychainStorage(key: "user", defaultValue: User(avatar: .defaultAvatar, userName: "", isCurrentUser: true)) var currentUser: User?
    @KeychainStorage(key: "ip", defaultValue: "") var ip: String?
    @KeychainStorage(key: "port", defaultValue: 0) var port: Int?
    @Published var room: ChatRoom? = nil
    @Published public var messages: [Message] = []
    @Published public var users: [User] = []
    @Published public var isConnected: Bool = false
    @Published public var status: Status = .standart
    @Published public var messageColor: Color = .blue
    @Published public var isIpVisible: Bool = false
    @Published public var backgroundColor: Color = .black
    @Published public var isDate: Bool = true
    @ObservedObject var router = Router<Path>(root: .login)
    init() {}
    func load() -> Self {
        self.username = self.username ?? ""
        self.currentUser = self.currentUser ?? User(avatar: .defaultAvatar, userName: "", isCurrentUser: true)
        self.currentUser?.isCurrentUser = true
        self.port = self.port ?? 45678
        return self
    }
    func clear() {
        self.username = self.username ?? ""
        self.currentUser = self.currentUser ?? User(avatar: .defaultAvatar, userName: "", isCurrentUser: true)
        self.ip = self.ip ?? "127.0.0.1"
        self.port = self.port ?? 45678
    }
}
