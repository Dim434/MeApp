//
//  URL+MIMEType.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation
import UniformTypeIdentifiers
extension URL {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}
