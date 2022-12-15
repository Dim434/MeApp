//
//  Router.swift
//  MeApp
//
//  Created by Dmitry on 12/15/22.
//

import Foundation
import SwiftUI


final class Router<T: Hashable>: ObservableObject {
    @Published var root: T
    @Published var paths: [T] = []

    init(root: T) {
        self.root = root
    }

    func push(_ path: T) {
        paths.append(path)
    }

    func pop() {
        paths.removeLast()
    }

    func updateRoot(root: T) {
        self.root = root
    }

    func popToRoot(){
       paths = []
    }
}
