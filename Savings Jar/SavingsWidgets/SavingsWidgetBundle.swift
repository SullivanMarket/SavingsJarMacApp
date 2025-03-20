//
//  SavingsWidgetBundle.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import WidgetKit
import SwiftUI

// Widget Bundle - Contains all widgets for the app
// Remove the @main attribute as it conflicts with the main app
struct SavingsWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Currently we only have one widget type, but we could add more here in the future
        SavingsWidgets()
    }
}
