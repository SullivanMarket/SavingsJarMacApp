//
//  CSVUtility.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import Foundation
//import Savings_Jar

class CSVUtility {
    // Safely escape string values for CSV
    static func escapeCSVValue(_ value: String) -> String {
        // Handle special characters in CSV
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
    
    // Convert a savings jar to a CSV row
    static func jarToCSVRow(_ jar: SavingsJar) -> String {
        // Convert transactions to a compact string representation
        let transactionsString = jar.transactions.map { transaction in
            // Use transaction.amount > 0 to determine if it's a deposit
            "\(transaction.amount > 0 ? "deposit" : "withdrawal"):\(abs(transaction.amount)):\(transaction.date.ISO8601Format())"
        }.joined(separator: ";")
        
        let dateFormatter = ISO8601DateFormatter()
        
        return [
            jar.id.uuidString,
            escapeCSVValue(jar.name),
            String(format: "%.2f", jar.targetAmount),
            String(format: "%.2f", jar.currentAmount),
            jar.color,
            jar.icon,
            dateFormatter.string(from: jar.creationDate),
            escapeCSVValue(transactionsString)
        ].joined(separator: ",")
    }
    
    // Parse a CSV row back into a SavingsJar
    static func csvRowToJar(_ row: String) -> SavingsJar? {
        // Careful CSV parsing that handles quoted fields
        var fields: [String] = []
        var currentField = ""
        var isInQuotes = false
        var escapeNextChar = false
        
        for char in row {
            if escapeNextChar {
                currentField.append(char)
                escapeNextChar = false
                continue
            }
            
            switch char {
            case "\"":
                // Fix the trailing closure warning by using parentheses
                if isInQuotes && (row.firstIndex(of: char).map { row.distance(from: row.startIndex, to: $0) } == fields.count) {
                    // Escaped quote within quoted field
                    currentField.append(char)
                } else {
                    isInQuotes.toggle()
                }
            case ",":
                if !isInQuotes {
                    fields.append(currentField)
                    currentField = ""
                } else {
                    currentField.append(char)
                }
            case "\\":
                escapeNextChar = true
            default:
                currentField.append(char)
            }
        }
        fields.append(currentField)
        
        // Validate we have enough fields
        guard fields.count >= 7 else { return nil }
        
        let dateFormatter = ISO8601DateFormatter()
        
        // Remove quotes from string fields
        func unquote(_ str: String) -> String {
            var result = str
            if result.hasPrefix("\"") && result.hasSuffix("\"") {
                result.removeFirst()
                result.removeLast()
            }
            return result.replacingOccurrences(of: "\"\"", with: "\"")
        }
        
        guard
            let id = UUID(uuidString: fields[0]),
            let targetAmount = Double(fields[2]),
            let currentAmount = Double(fields[3]),
            let creationDate = dateFormatter.date(from: fields[6])
        else { return nil }
        
        // Parse transactions
        let transactions: [Transaction] = fields.count > 7
            ? parseTransactions(unquote(fields[7]))
            : []
        
        return SavingsJar(
            id: id,
            name: unquote(fields[1]),
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            color: fields[4],
            icon: fields[5],
            creationDate: creationDate,
            transactions: transactions
        )
    }
    
    // Parse transaction string back into Transaction objects
    static func parseTransactions(_ transactionString: String) -> [Transaction] {
        guard !transactionString.isEmpty else { return [] }
        
        return transactionString.split(separator: ";").compactMap { transactionData in
            let parts = transactionData.split(separator: ":")
            guard
                parts.count == 3,
                let amount = Double(parts[1]),
                let date = ISO8601DateFormatter().date(from: String(parts[2]))
            else { return nil }
            
            // Use the deposit/withdrawal indicator to set the sign
            let finalAmount = parts[0] == "deposit" ? amount : -amount
            
            return Transaction(
                amount: finalAmount,
                date: date
            )
        }
    }
}
