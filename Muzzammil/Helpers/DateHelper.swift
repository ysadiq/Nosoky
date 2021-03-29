//
//  DateHelper.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

enum DateHelper {
    public static func string(
        from date: Date = Date(),
        dateFormat: String = "yyyy-MM-dd"
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }

    public static func date(
        from string: String,
        format: String = "yyyy-MM-dd"
    ) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string) ?? Date()
    }
}
