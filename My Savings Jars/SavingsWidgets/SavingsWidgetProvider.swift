//
//  SavingsWidgetProvider.swift
//  MySavingsWidgetsExtension
//
//  Created by Sean Sullivan on 3/23/25.
//

import WidgetKit
import SwiftUI

struct SavingsWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SavingsWidgetEntry {
        let now = Date()
        return SavingsWidgetEntry(date: now, jar: nil, jars: [], timestamp: now)
    }

    func snapshot(for configuration: SelectJarIntent, in context: Context) async -> SavingsWidgetEntry {
        let selectedJars = (configuration.jars ?? []).compactMap { entity in
            SavingsDataProvider.shared.loadJar(matching: entity.id)
        }

        let firstJar = selectedJars.first
        let now = Date()

        return SavingsWidgetEntry(date: now, jar: firstJar, jars: selectedJars, timestamp: now)
    }

    func timeline(for configuration: SelectJarIntent, in context: Context) async -> Timeline<SavingsWidgetEntry> {
        let selectedJars = (configuration.jars ?? []).compactMap { entity in
            SavingsDataProvider.shared.loadJar(matching: entity.id)
        }

        let now = Date()
        let entry = SavingsWidgetEntry(
            date: now,
            jar: selectedJars.first,
            jars: selectedJars,
            timestamp: now
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: now)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}
