//
//  CurrencyField.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/29/25.
//

import SwiftUI

// Helper struct for handling number input with automatic cents
struct CurrencyField: View {
    @Binding var text: String
    var placeholder: String
    var onEditingChanged: (Bool) -> Void = { _ in }
    
    // Track internal editing state
    @State private var isEditing = false
    
    var body: some View {
        TextField(placeholder, text: $text, onEditingChanged: { editing in
            // When losing focus, add cents if needed
            if !editing && isEditing {
                addCentsIfNeeded()
            }
            
            // Update internal editing state
            isEditing = editing
            
            // Pass along the editing state change
            onEditingChanged(editing)
        })
    }
    
    // Helper function to add cents when needed
    private func addCentsIfNeeded() {
        // Only process non-empty text
        guard !text.isEmpty else { return }
        
        // Trim any whitespace
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any non-numeric characters except decimal points
        text = text.filter { "0123456789.".contains($0) }
        
        // Ensure there's only one decimal point
        let components = text.components(separatedBy: ".")
        if components.count > 2 {
            // Multiple decimal points - keep only the first one
            if let firstPart = components.first {
                let remainingParts = components.dropFirst().joined()
                text = firstPart + "." + remainingParts
            }
        }
        
        // Check if text already contains cents (has a decimal point)
        if !text.contains(".") {
            // No decimal point, so append ".00"
            text += ".00"
        } else {
            // Has decimal point, check the format
            let components = text.components(separatedBy: ".")
            if components.count == 2 {
                let centsString = components[1]
                if centsString.isEmpty {
                    // Decimal with nothing after, like "100."
                    text += "00"
                } else if centsString.count == 1 {
                    // Has one digit after decimal, like "100.5"
                    text += "0"
                } else if centsString.count > 2 {
                    // More than 2 digits after decimal, truncate to 2
                    let index = centsString.index(centsString.startIndex, offsetBy: 2)
                    text = components[0] + "." + centsString.prefix(upTo: index)
                }
            }
        }
        
        // Handle case where text is just a decimal point
        if text == "." {
            text = "0.00"
        }
    }
}

// Extension to convert between String and Double
extension CurrencyField {
    // Convert a Double value to a formatted currency String
    static func formatValue(_ value: Double) -> String {
        if value == Double(Int(value)) {
            // Value is a whole number
            return String(format: "%.0f", value)
        } else {
            // Value has decimal part
            return String(format: "%.2f", value)
        }
    }
    
    // Convert a String to a Double, returns 0 if conversion fails
    static func parseValue(_ text: String) -> Double {
        return Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
}
