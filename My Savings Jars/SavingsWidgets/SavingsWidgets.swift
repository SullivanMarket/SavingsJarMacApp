//
//  SavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import WidgetKit
import SwiftUI

@main
struct SavingsWidgetsBundle: WidgetBundle {
    var body: some Widget {
        SavingsWidget()
    }
}

struct SavingsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SavingsWidget", provider: SavingsWidgetProvider()) { entry in
            SavingsWidgetView(entry: entry)
        }
        .configurationDisplayName("Savings Jar")
        .description("Track your savings progress")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SavingsWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SavingsWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallSavingsWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        case .systemMedium:
            MediumSavingsWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        case .systemLarge:
            LargeSavingsWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        default:
            SmallSavingsWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
    }
}

// For preview purposes only
struct MockWidgetEntry: View {
    var body: some View {
        Text("Widget Preview")
            .padding()
            .containerBackground(.blue.opacity(0.2), for: .widget)
    }
}

#Preview {
    MockWidgetEntry()
}
