//
//  ImagePreviewView.swift
//  MeApp
//
//  Created by Dmitry on 12/15/22.
//

import Foundation
import SwiftUI

struct ImagePreviewView: View {
    var image: UIImage
    var body: some View {
        ZoomableScrollView {
            Image(uiImage: image)
        }
    }
}
