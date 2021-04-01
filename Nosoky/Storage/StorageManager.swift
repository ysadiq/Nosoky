//
//  StorageManager.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/31/21.
//

import Foundation

class StorageManager {
    // MARK: - Initializer
    public static let shared = StorageManager()
    private init() {}

    // MARK: - Public methods
    func save(_ data: Data) {
        let fileName = DateHelper.string(dateFormat: "MMMM_yyyy")
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("\(fileName).json")

        try? data.write(to: path)
    }

    func load() -> Data? {
        let fileName = DateHelper.string(dateFormat: "MMMM_yyyy")
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).json") else {
            return nil
        }

        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            return nil
        }
    }
}
