//
//  MessageDTO.swift
//  MeApp
//
//  Created by Dmitry on 12/11/22.
//

import Foundation
import SwiftUI
import CommonCrypto

class MessageDTO: Codable {
    static func MD5(string: String) -> Data {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            let messageData = string.data(using:.utf8)!
            var digestData = Data(count: length)

            _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                messageData.withUnsafeBytes { messageBytes -> UInt8 in
                    if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(messageData.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                    return 0
                }
            }
            return digestData
        }
    let contentType: String
    let data: String
    init(from msg: MessageType) {
        switch msg {
        case .msg(let str):
            self.contentType = "text/plain"
            self.data = str
        case .file(let name, let data):
            self.contentType = "data"
            self.data = "\(name)||\(data.base64EncodedString())||\(MessageDTO.MD5(string: data.base64EncodedString()).map { String(format: "%02hhx", $0) }.joined())"
        case .image(let image):
            self.contentType = "image/png"
            self.data = image.pngData()?.base64EncodedString() ?? ""
        }
    }
    func decode() -> MessageType? {
        if contentType == "text/plain" {
            return .msg(data)
        }
        if contentType == "data" {
            let comps = data.components(separatedBy: "||")
            let data = Data(base64Encoded: comps[1].data(using: .utf8) ?? Data()) ?? Data()
            return .file(comps[0], data)
        }
        if contentType == "image/png" {
            return .image(UIImage.init(data: Data(base64Encoded: data.data(using: .utf8) ?? Data()) ?? Data()) ?? UIImage())
        }
        return nil
    }
}
