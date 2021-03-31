//
//  NSStorageManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import Foundation

class NSStorageManager {
    // MARK: - Initializer
    public static let shared = NSStorageManager()
    private init() {}

    // MARK: - Public methods
    func save(_ data: Data) {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("this_month.json")

        try? data.write(to: path)
    }

    func load() -> Data? {

        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("this_month.json") else {
            return nil
        }

        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        }

        catch {
            return nil
        }
    }
}
