//
//  Created by Антон Лобанов on 26.02.2021.
//

import Foundation
import Security
import SwiftUI

public enum KeychainStoreError: Error {
    case keyNotFound
}

/// A value that is stored in the keychain.
@propertyWrapper
struct KeychainStorage<T: Codable>: DynamicProperty {
    typealias Value = T
    // MARK: State

    /// The value that is stored in the keychain.
    @State var value: Value?
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    init(value: Value? = nil, key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self._value = State<Value?>(initialValue: get(key: key) ?? defaultValue)
    }
    var wrappedValue: Value? {
        get {
            value
        }
        set {
            store(value: newValue)
        }
    }
    var projectedValue: Binding<Value?> {
        Binding(get: { wrappedValue }, set: { container.set($0, forKey: key) })
    }
    func store(value: T?) {
        guard let data = try? JSONEncoder().encode(value) else {return}
        container.set(data, forKey: key)
    }
    func get(key: String) -> T? {
        let data = container.data(forKey: key)
        return try? JSONDecoder().decode(T.self, from: data ?? Data())
    }
}
