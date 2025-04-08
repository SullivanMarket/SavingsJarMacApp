//
//  SavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import WidgetKit
import SwiftUI

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
            if let selected = entry.widgetData.selectedJar {
                let widgetJar = WidgetJarData(
                    id: selected.id,
                    name: selected.name,
                    currentAmount: selected.currentAmount,
                    targetAmount: selected.targetAmount,
                    color: selected.color,
                    icon: selected.icon,
                    progressPercentage: selected.targetAmount > 0
                        ? selected.currentAmount / selected.targetAmount
                        : 0.0
                )

                SmallSavingsWidgetView(jar: widgetJar)
                    .containerBackground(.background, for: .widget)
            } else {
                Text("No eligible jars")
            }

        case .systemMedium:
            MediumSavingsWidgetView(jars: entry.widgetData.allJars.map {
                WidgetJarData(
                    id: $0.id,
                    name: $0.name,
                    currentAmount: $0.currentAmount,
                    targetAmount: $0.targetAmount,
                    color: $0.color,
                    icon: $0.icon,
                    progressPercentage: $0.targetAmount > 0
                        ? $0.currentAmount / $0.targetAmount
                        : 0.0
                )
            })
            .containerBackground(.background, for: .widget)

        case .systemLarge:
            LargeSavingsWidgetView(jars: entry.widgetData.allJars.map {
                WidgetJarData(
                    id: $0.id,
                    name: $0.name,
                    currentAmount: $0.currentAmount,
                    targetAmount: $0.targetAmount,
                    color: $0.color,
                    icon: $0.icon,
                    progressPercentage: $0.targetAmount > 0
                        ? $0.currentAmount / $0.targetAmount
                        : 0.0
                )
            })
            .containerBackground(.background, for: .widget)

        default:
            Text("Not Supported")
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
