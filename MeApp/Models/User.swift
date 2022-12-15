//
//  User.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation
import SwiftUI
public class User: Identifiable, Codable {
    public enum CodingKeys: String, CodingKey {
//        case avatar = "avatar"
        case userName = "username"
        case ip = "ip"
    }
//    @Published var avatar: UIImage
    @Published var userName: String
    @Published var isCurrentUser: Bool
    @Published var ip: String = ""
    init(avatar _: UIImage, userName: String, isCurrentUser: Bool) {
//        self.avatar = avatar
        self.userName = userName
        self.isCurrentUser = isCurrentUser
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ip, forKey: .ip)
        try container.encode(userName, forKey: .userName)
//        try container.encode(avatar.pngData()?.base64EncodedString(), forKey: .avatar)
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.avatar = UIImage(data: Data(base64Encoded: try container.decode(String.self, forKey: .avatar).data(using: .utf8) ?? Data()) ?? Data()) ?? UIImage()
        self.userName = try container.decode(String.self, forKey: .userName)
        self.ip = try container.decode(String.self, forKey: .ip)
        self.isCurrentUser = false
    }
}
