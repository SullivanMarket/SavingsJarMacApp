//
//  SavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import WidgetKit
import SwiftUI

struct SavingsWidgets: Widget {
    private let kind = "SavingsWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: SavingsWidgetProvider()
        ) { entry in
            SavingsWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Savings Jar")
        .description("Keep track of your savings progress")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SavingsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: SavingsWidgetProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallSavingsWidgetView(entry: entry)
        case .systemMedium:
            MediumSavingsWidgetView(entry: entry)
        case .systemLarge:
            LargeSavingsWidgetView(entry: entry)
        @unknown default:
            SmallSavingsWidgetView(entry: entry)
        }
    }
}
