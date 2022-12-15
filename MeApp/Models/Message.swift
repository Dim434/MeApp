//
//  ChatMessage.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation

@MainActor public class Message: Identifiable, Hashable, Equatable, Codable {
    nonisolated public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.user.userName == rhs.user.userName
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(self.user.userName)
    }
    public enum CodingKeys: String, CodingKey {
        case user = "user"
        case message = "message"
    }
    let user: User
    let messageType: MessageType
    let time: Date
    init(user: User, messageType: MessageType) {
        self.user = user
        self.messageType = messageType
        self.time = Date()
    }
    nonisolated public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decode(User.self, forKey: .user)
        let msgType = try container.decode(MessageDTO.self, forKey: .message)
        self.messageType = msgType.decode() ?? .msg("Empty message")
        self.time = Date()
    }
    nonisolated public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(MessageDTO(from: self.messageType), forKey: .message)
        try container.encode(self.user, forKey: .user)
    }
}
