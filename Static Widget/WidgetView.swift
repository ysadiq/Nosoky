//
//  WidgetView.swift
//  Muzzammil
//
//  Created by Yahya Saddiq on 3/22/21.
//

import SwiftUI
import WidgetKit

struct WidgetData {
    let nextPrayerTime: String
    let date: Date
}

extension WidgetData {
    static let previewData = WidgetData(
        nextPrayerTime: PrayerManager.shared.nextPrayer?.time ?? "not found",
        date: Date().advanced(by: (-60*29))
    )
}

struct WidgetView: View {
    let data: WidgetData

    var body: some View {
        Text(data.nextPrayerTime)
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetView(data: .previewData)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
