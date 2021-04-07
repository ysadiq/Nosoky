//
//  DateHelper.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 3/22/21.
//

import Foundation

enum DateHelper {
    public static func string(
        from date: Date = Date(),
        dateFormat: String = "yyyy-MM-dd",
        calendar: Calendar.Identifier = .gregorian
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.calendar = Calendar(identifier: calendar)
        return dateFormatter.string(from: date)
    }

    public static func date(
        from string: String,
        format: String = "yyyy-MM-dd",
        calendar: Calendar.Identifier = .gregorian
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.calendar = Calendar(identifier: calendar)
        return dateFormatter.date(from: string)
    }
}
