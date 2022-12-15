//
//  ChatMessage.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation
import UIKit

public enum MessageType {
    case msg(String)
    case file(String, Data)
    case image(UIImage)
}
