//
//  CSVUtility.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import Foundation

class CSVUtility {
    static func createCSV(from savingsJar: SavingsJar) -> String {
        var csvString = "Date,Amount,Note,Type\n"
        
        for transaction in savingsJar.transactions {
            let dateString = formatDate(transaction.date)
            let amountString = formatAmount(abs(transaction.amount))
            let noteString = transaction.note
            let typeString = transaction.amount >= 0 ? "Deposit" : "Withdrawal"
            
            let rowString = "\(dateString),\(amountString),\(noteString),\(typeString)\n"
            csvString.append(rowString)
        }
        
        return csvString
    }

    static func createSavingsJar(from csvString: String, existingJar: SavingsJar? = nil) -> SavingsJar? {
        let lines = csvString.components(separatedBy: .newlines)
        
        guard let headerLine = lines.first else {
            print("Invalid CSV format: missing header")
            return nil
        }
        
        let headers = headerLine.components(separatedBy: ",")
        guard headers == ["Date", "Amount", "Note", "Type"] else {
            print("Invalid CSV format: incorrect headers")
            return nil
        }

        var transactions: [SavingsTransaction] = []

        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }

            let values = line.components(separatedBy: ",")

            guard values.count == 4 else {
                print("Invalid CSV format at line \(index + 1): incorrect number of values")
                continue
            }

            let dateString = values[0]
            let amountString = values[1]
            let noteString = values[2]
            let typeString = values[3]

            guard let date = parseDate(dateString),
                  let amount = parseAmount(amountString) else {
                print("Invalid date or amount format at line \(index + 1)")
                continue
            }

            let signedAmount = (typeString == "Deposit") ? abs(amount) : -abs(amount)

            let transaction = SavingsTransaction(
                id: UUID(), // <- Add this line
                date: date,
                amount: signedAmount,
                note: noteString
            )

            transactions.append(transaction)
        }

        if let jar = existingJar {
            var updatedJar = jar
            updatedJar.transactions = transactions
            updatedJar.currentAmount = transactions.reduce(0) { $0 + $1.amount }
            return updatedJar
        } else {
            return SavingsJar(
                name: "Imported Jar",
                currentAmount: transactions.reduce(0) { $0 + $1.amount },
                targetAmount: 0,
                color: "blue",
                icon: "banknote",
                transactions: transactions,
                creationDate: Date()
            )
        }
    }

    // MARK: - Helpers

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }

    private static func formatAmount(_ amount: Double) -> String {
        return String(format: "%.2f", amount)
    }

    private static func parseAmount(_ string: String) -> Double? {
        return Double(string)
    }
}
