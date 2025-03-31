//
//  SavingsWidgetIntent.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 3/28/25.
//

import WidgetKit
import AppIntents

struct SelectJarIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Savings Jar"
    static var description = IntentDescription("Choose which savings jar to display")

    @Parameter(title: "Savings Jar")
    var jarID: String?
    
    init() {
        self.jarID = nil
    }
    
    init(jarID: String?) {
        self.jarID = jarID
    }
}
