//
//  NumberFormattingExtensions.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/10/25.
//

import Foundation

extension Double {
    func asCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }

    func formattedCompact() -> String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        } else {
            return String(format: "%.0f", self)
        }
    }
}
