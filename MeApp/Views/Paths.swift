//
//  Paths.swift
//  MeApp
//
//  Created by Dmitry on 12/15/22.
//

import Foundation
import UIKit

enum Path: Hashable {
    case login
    case chat
    case settings(SettingsType)
    case xmlImporter
    case xmlExporter
    case uiSettings
    case imagePreview(UIImage)
}
