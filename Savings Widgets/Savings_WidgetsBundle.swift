//
//  Savings_WidgetsBundle.swift
//  Savings Widgets
//
//  Created by Sean Sullivan on 3/19/25.
//

import WidgetKit
import SwiftUI

@main
struct Savings_WidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        SavingsWidgets()
    }
}
