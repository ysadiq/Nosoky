//
//  NotificationContent.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/7/21.
//

import Foundation

struct NotificationContent {
    let id: String
    var title: String, subtitle: String?, body: String?
    let sound: Sound?
    let dateComponents: DateComponents

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        body: String? = nil,
        sound: Sound? = nil,
        dateComponents: DateComponents) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.sound = sound
        self.dateComponents = dateComponents
    }
}
