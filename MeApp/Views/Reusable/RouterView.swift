//
//  RouterView.swift
//  MeApp
//
//  Created by Dmitry on 12/15/22.
//

import Foundation
import SwiftUI
struct RouterView<T: Hashable, Content: View>: View {
    
    @ObservedObject
    var router: Router<T>
    
    @ViewBuilder var buildView: (T) -> Content
    var body: some View {
        NavigationStack(path: $router.paths) {
            buildView(router.root)
            .navigationDestination(for: T.self) { path in
                buildView(path)
            }
        }
        .environmentObject(router)
    }
}
