//
//  SavingsWidgetIntent.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 3/28/25.
//

import AppIntents
import WidgetKit

struct SelectJarIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Savings Jars"
    static var description = IntentDescription("Choose savings jars to display in the widget")

    @Parameter(title: "Savings Jars")
    var jars: [JarSelectionEntity]?
}
