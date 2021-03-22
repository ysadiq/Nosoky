//
//  DateHelper.swift
//  AllahuAkbar
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

enum DateHelper {
    public static func string(
        from date: Date = Date(),
        format: String? = nil,
        dateFormat: String = "yyyy-MM-dd",
        locale: Locale? = nil
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}
