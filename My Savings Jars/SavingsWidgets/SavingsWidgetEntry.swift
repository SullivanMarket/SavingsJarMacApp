//
//  SavingsWidgetEntry.swift
//  MySavingsWidgetsExtension
//
//  Created by Sean Sullivan on 3/23/25.
//

import WidgetKit
import Foundation

struct SavingsWidgetEntry: TimelineEntry {
    let date: Date
    let jar: WidgetJarData?     // For small widget
    let jars: [WidgetJarData]   // For medium and large widgets
    let timestamp: Date // Already used by TimelineEntry
}
