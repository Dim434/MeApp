//
//  MessageDocument.swift
//  MeApp
//
//  Created by Dmitry on 12/10/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MessageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.data, .xml] }

    var message: Data

    init(message: Data) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message)
    }
    
}
