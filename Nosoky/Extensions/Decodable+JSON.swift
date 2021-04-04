//
//  Decodable+JSON.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/4/21.
//

import Foundation

public extension Decodable {
    init?(JSONString: String?) {
        guard let json = JSONString,
            let jsonData = json.data(using: .utf8),
            let anInstance = try? JSONDecoder().decode(Self.self, from: jsonData) else {
                return nil
        }
        self = anInstance
    }
}
