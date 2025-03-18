//
//  SavingsJarApp.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#endif

// Custom font extension
extension Font {
    static let fancyTitle = Font.custom("Georgia", size: 28).bold().italic()
    static let fancyHeading = Font.custom("Georgia", size: 22).bold()
}

// MARK: - Models
struct SavingsJar: Identifiable, Codable {
    var id = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var color: String // Store as string, convert to Color in the view
    var icon: String
    var creationDate = Date()
    var transactions: [Transaction] = []
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var date: Date
    var isDeposit: Bool {
        return amount > 0
    }
}

// MARK: - Formatters
class CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
    }
    
    func string(from value: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// Create a date formatter for reuse
func createDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}

// MARK: - View Models
class SavingsViewModel: ObservableObject {
    @Published var savingsJars: [SavingsJar] = []
    @Published var selectedJarForTransaction: SavingsJar?
    @Published var showingTransactionPopup = false
    
    let formatter = CurrencyFormatter.shared
    
    init() {
        loadSavingsJars()
    }
    
    func addSavingsJar(_ jar: SavingsJar) {
        savingsJars.append(jar)
        saveSavingsJars()
    }
    
    func saveSavingsJars() {
        let csvString = savingsJarsToCSV()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("savingsJars.csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing to CSV file: \(error)")
        }
    }
    
    func savingsJarsToCSV() -> String {
        var csvString = "id,name,targetAmount,currentAmount,color,icon,creationDate,transactions\n"
        
        for jar in savingsJars {
            let creationDateString = ISO8601DateFormatter().string(from: jar.creationDate)
            
            // Convert transactions to a readable CSV-friendly format
            let transactionsString = jar.transactions.map { transaction in
                let dateString = ISO8601DateFormatter().string(from: transaction.date)
                return "\(transaction.amount)|\(dateString)"
            }.joined(separator: ";")
            
            let escapedName = jar.name.replacingOccurrences(of: ",", with: "_")
            
            let row = "\(jar.id),\(escapedName),\(jar.targetAmount),\(jar.currentAmount),\(jar.color),\(jar.icon),\(creationDateString),\(transactionsString)\n"
            csvString.append(row)
        }
        
        return csvString
    }

    func loadSavingsJars() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("savingsJars.csv")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let csvString = try String(contentsOf: fileURL, encoding: .utf8)
                let lines = csvString.components(separatedBy: .newlines)
                
                var loadedJars: [SavingsJar] = []
                
                for line in lines.dropFirst() {
                    let values = line.components(separatedBy: ",")
                    if values.count == 8 {
                        let id = UUID(uuidString: values[0]) ?? UUID()
                        let name = values[1]
                        let targetAmount = Double(values[2]) ?? 0
                        let currentAmount = Double(values[3]) ?? 0
                        let color = values[4]
                        let icon = values[5]
                        let creationDate = ISO8601DateFormatter().date(from: values[6]) ?? Date()
                        
                        // Decode transactions
                        var transactions: [Transaction] = []
                        let transactionsString = values[7]
                        if !transactionsString.isEmpty {
                            let transactionStrings = transactionsString.components(separatedBy: ";")
                            transactions = transactionStrings.compactMap { transactionString in
                                let parts = transactionString.components(separatedBy: "|")
                                guard parts.count == 2,
                                      let amount = Double(parts[0]),
                                      let date = ISO8601DateFormatter().date(from: parts[1]) else {
                                    return nil
                                }
                                return Transaction(amount: amount, date: date)
                            }
                        }
                        
                        let jar = SavingsJar(
                            id: id,
                            name: name,
                            targetAmount: targetAmount,
                            currentAmount: currentAmount,
                            color: color,
                            icon: icon,
                            creationDate: creationDate,
                            transactions: transactions
                        )
                        loadedJars.append(jar)
                    }
                }
                
                self.savingsJars = loadedJars
            } catch {
                print("Error loading savings jars from CSV: \(error)")
                loadSampleData()
            }
        } else {
            print("Savings jars CSV file not found. Loading sample data.")
            loadSampleData()
        }
    }

    func loadSampleData() {
        let sampleTransactions1 = [
            Transaction(amount: 100, date: Date().addingTimeInterval(-86400 * 5)),
            Transaction(amount: -25, date: Date().addingTimeInterval(-86400 * 3)),
            Transaction(amount: 50, date: Date().addingTimeInterval(-86400 * 1))
        ]
        
        let sampleTransactions2 = [
            Transaction(amount: 150, date: Date().addingTimeInterval(-86400 * 7)),
            Transaction(amount: 50, date: Date().addingTimeInterval(-86400 * 4)),
            Transaction(amount: -30, date: Date().addingTimeInterval(-86400 * 2))
        ]
        
        let sampleTransactions3 = [
            Transaction(amount: 500, date: Date().addingTimeInterval(-86400 * 10)),
            Transaction(amount: 200, date: Date().addingTimeInterval(-86400 * 6)),
            Transaction(amount: -100, date: Date().addingTimeInterval(-86400 * 3))
        ]
        
        self.savingsJars = [
            SavingsJar(name: "Vacation", targetAmount: 2000, currentAmount: 750, color: "blue", icon: "airplane", transactions: sampleTransactions1),
            SavingsJar(name: "New Phone", targetAmount: 1000, currentAmount: 350, color: "purple", icon: "iphone", transactions: sampleTransactions2),
            SavingsJar(name: "Emergency Fund", targetAmount: 5000, currentAmount: 2000, color: "red", icon: "heart.circle", transactions: sampleTransactions3)
        ]
    }
    
    func updateSavingsJar(id: UUID, amount: Double) {
        if let index = savingsJars.firstIndex(where: { $0.id == id }) {
            // Add the transaction
            let transaction = Transaction(amount: amount, date: Date())
            savingsJars[index].transactions.append(transaction)
            
            // Limit to last 10 transactions
            if savingsJars[index].transactions.count > 10 {
                savingsJars[index].transactions.removeFirst(
                    savingsJars[index].transactions.count - 10
                )
            }
            
            // Update the balance
            savingsJars[index].currentAmount += amount
            
            saveSavingsJars()
        }
    }
    
    func deleteSavingsJar(at indexSet: IndexSet) {
        savingsJars.remove(atOffsets: indexSet)
        saveSavingsJars()
    }
    
    func deleteSavingsJar(with id: UUID) {
        if let index = savingsJars.firstIndex(where: { $0.id == id }) {
            savingsJars.remove(at: index)
            saveSavingsJars()
        }
    }
    
    func getColorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    func showTransactionFor(jar: SavingsJar) {
        selectedJarForTransaction = jar
        showingTransactionPopup = true
    }
    
    // MARK: - Export and Import Methods
    func exportJars(to url: URL) {
        let csvString = savingsJarsToCSV()
        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
            print("Jars exported successfully to \(url.path)")
        } catch {
            print("Error exporting jars: \(error)")
        }
    }
    
    func importJars(from url: URL) throws {
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let lines = csvString.components(separatedBy: .newlines)
            
            // Validate the CSV has a header and at least one data row
            guard lines.count > 1, lines[0].contains("id,name,targetAmount") else {
                print("Invalid CSV format")
                throw NSError(domain: "ImportError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid CSV format"])
            }
            
            var loadedJars: [SavingsJar] = []
            
            // Skip the header row
            for line in lines.dropFirst() {
                // Trim any whitespace
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines
                guard !trimmedLine.isEmpty else { continue }
                
                let values = line.components(separatedBy: ",")
                
                // Ensure we have enough values
                guard values.count >= 7 else {
                    print("Skipping invalid line: \(line)")
                    continue
                }
                
                do {
                    let id = UUID(uuidString: values[0]) ?? UUID()
                    let name = values[1]
                    let targetAmount = Double(values[2]) ?? 0
                    let currentAmount = Double(values[3]) ?? 0
                    let color = values[4]
                    let icon = values[5]
                    let creationDate = ISO8601DateFormatter().date(from: values[6]) ?? Date()
                    
                    // Decode transactions if available
                    var transactions: [Transaction] = []
                    if values.count == 8 && !values[7].isEmpty {
                        let transactionsString = values[7]
                        let transactionStrings = transactionsString.components(separatedBy: ";")
                        transactions = transactionStrings.compactMap { transactionString in
                            let parts = transactionString.components(separatedBy: "|")
                            guard parts.count == 2,
                                  let amount = Double(parts[0]),
                                  let date = ISO8601DateFormatter().date(from: parts[1]) else {
                                return nil
                            }
                            return Transaction(amount: amount, date: date)
                        }
                    }
                    
                    let jar = SavingsJar(
                        id: id,
                        name: name,
                        targetAmount: targetAmount,
                        currentAmount: currentAmount,
                        color: color,
                        icon: icon,
                        creationDate: creationDate,
                        transactions: transactions
                    )
                    loadedJars.append(jar)
                }// catch {
                  //  print("Error processing jar: \(error)")
                //}
            }
            
            // Only replace jars if we successfully loaded some
            guard !loadedJars.isEmpty else {
                print("No valid jars found in the import file")
                throw NSError(domain: "ImportError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No valid jars found"])
            }
            
            // Replace existing jars with imported jars
            self.savingsJars = loadedJars
            
            // Save the imported jars to the default location
            saveSavingsJars()
            
            print("Successfully imported \(loadedJars.count) jars")
        } catch {
            print("Error importing jars: \(error)")
            throw error
        }
    }

    // MARK: - Main Views
    struct ContentView: View {
        @StateObject private var viewModel = SavingsViewModel()
        @State private var showingAddJar = false
        @State private var selectedJarId: UUID?
        
        // Add this as a method in the ContentView or as a separate view
        private func showAboutView() {
            #if os(macOS)
            // Use NSPanel instead of NSWindow for better behavior
            let aboutPanel = NSPanel(
                contentRect: NSRect(x: 100, y: 100, width: 400, height: 250),
                styleMask: [.titled, .closable, .miniaturizable, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            aboutPanel.title = "About Savings Jar"
            aboutPanel.isFloatingPanel = true
            
            // Get the version from the bundle
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0"
            
            // Create a weak reference to avoid retain cycles
            weak var weakPanel = aboutPanel
            
            aboutPanel.contentView = NSHostingView(rootView:
                VStack(spacing: 15) {
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Savings Jar")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 Sullivan Market LLC")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Manage and track your savings goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    // Add a close button
                    Button("Close") {
                        weakPanel?.close()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(width: 400, height: 250)
                .padding()
            )
            
            aboutPanel.center()
            aboutPanel.makeKeyAndOrderFront(nil)
            #endif
        }
        
        private func exportJarsAction() {
            #if os(macOS)
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.commaSeparatedText]
            savePanel.nameFieldStringValue = "savings_jars.csv"
            
            if savePanel.runModal() == .OK {
                if let url = savePanel.url {
                    viewModel.exportJars(to: url)
                }
            }
            #endif
        }

        private func importJarsAction() {
            #if os(macOS)
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = [.commaSeparatedText]
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.allowsMultipleSelection = false
            
            if openPanel.runModal() == .OK {
                if let url = openPanel.url {
                    do {
                        try viewModel.importJars(from: url)
                        // Show success alert
                        let alert = NSAlert()
                        alert.messageText = "Import Successful"
                        alert.informativeText = "Your savings jars have been imported."
                        alert.alertStyle = .informational
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    } catch {
                        // Show error alert
                        let alert = NSAlert()
                        alert.messageText = "Import Failed"
                        alert.informativeText = "There was an error importing your savings jars. \(error.localizedDescription)"
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
            #endif
        }
        
        var body: some View {
            NavigationSplitView {
                List(selection: $selectedJarId) {
                    Section(header: Text("Summary")) {
                        NavigationLink(value: UUID()) {
                            Label("All Savings", systemImage: "dollarsign.circle.fill")
                        }
                    }
                    
                    Section {
                        ForEach(viewModel.savingsJars) { jar in
                            NavigationLink(value: jar.id) {
                                HStack {
                                    Image(systemName: jar.icon)
                                        .foregroundColor(viewModel.getColorFromString(jar.color))
                                    Text(jar.name)
                                    Spacer()
                                    Text(viewModel.formatter.string(from: jar.currentAmount))
                                        .foregroundColor(.secondary)
                                }
                                .contextMenu {
                                    Button {
                                        viewModel.showTransactionFor(jar: jar)
                                    } label: {
                                        Label("Deposit / Withdraw", systemImage: "arrow.left.arrow.right.circle.fill")
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteSavingsJar(at: indexSet)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("")
                    }
                    
                    ToolbarItemGroup(placement: .automatic) {
                        Button(action: exportJarsAction) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: importJarsAction) {
                            Label("Import", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: {
                            showingAddJar = true
                        }) {
                            Label("Add Jar", systemImage: "plus")
                        }
                        
                        Button(action: showAboutView) {
                                Label("About", systemImage: "info.circle")
                            }
                    }
                }
                .navigationTitle("")
            } detail: {
                if let jarId = selectedJarId, jarId != UUID(), let jar = viewModel.savingsJars.first(where: { $0.id == jarId }) {
                    SavingsJarDetailView(jar: jar, viewModel: viewModel)
                } else {
                    // Overview screen
                    SavingsOverviewView(savingsJars: viewModel.savingsJars, viewModel: viewModel)
                }
            }
            .frame(minWidth: 900, minHeight: 600)
            .overlay {
                if showingAddJar {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingAddJar = false
                        }
                    
                    ZStack {
                        CustomAddJarView(viewModel: viewModel, isPresented: $showingAddJar)
                    }
                    .frame(width: 400, height: 550)
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $viewModel.showingTransactionPopup) {
                if let jar = viewModel.selectedJarForTransaction {
                    TransactionSliderView(
                        jar: jar,
                        viewModel: viewModel,
                        isVisible: $viewModel.showingTransactionPopup
                    )
                    .frame(width: 380, height: 350)
                    .padding([.horizontal, .top, .bottom], 10)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showingAddJar)
        }
    }
    
    struct SavingsOverviewView: View {
        let savingsJars: [SavingsJar]
        @ObservedObject var viewModel: SavingsViewModel
        let formatter = CurrencyFormatter.shared
        
        var totalSaved: Double {
            savingsJars.reduce(0) { $0 + $1.currentAmount }
        }
        
        var totalTarget: Double {
            savingsJars.reduce(0) { $0 + $1.targetAmount }
        }
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Total Savings")
                        .font(.fancyTitle)
                        .padding(.top)
                    
                    // Total savings card
                    VStack(spacing: 15) {
                        HStack {
                            Text("Total Progress")
                                .font(.headline)
                            Spacer()
                            Text(formatter.string(from: totalSaved))
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        ProgressBar(value: totalSaved / totalTarget, color: .blue)
                        
                        HStack {
                            Text("\(formatter.string(from: totalSaved)) of \(formatter.string(from: totalTarget))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f%%", (totalSaved / totalTarget) * 100))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(12)
                    
                    Text("All Savings Jars")
                        .font(.fancyHeading)
                        .padding(.top)
                    
                    // Grid of savings jars
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                        ForEach(savingsJars) { jar in
                            SavingsJarCard(jar: jar, viewModel: viewModel)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
    
    struct SavingsJarCard: View {
        let jar: SavingsJar
        @ObservedObject var viewModel: SavingsViewModel
        let formatter = CurrencyFormatter.shared
        
        var color: Color {
            switch jar.color {
            case "red": return .red
            case "green": return .green
            case "blue": return .blue
            case "purple": return .purple
            case "orange": return .orange
            case "yellow": return .yellow
            default: return .blue
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: jar.icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Text(jar.name)
                        .font(.headline)
                    Spacer()
                    
                    Button {
                        viewModel.showTransactionFor(jar: jar)
                    } label: {
                        Text("Deposit / Withdraw")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(color)
                    }
                    .buttonStyle(.plain)
                    .help("Add or withdraw money")
                }
                
                Text(formatter.string(from: jar.currentAmount))
                    .font(.title3)
                    .fontWeight(.bold)
                
                ProgressBar(value: jar.percentComplete, color: color)
                
                HStack {
                    Text("\(formatter.string(from: jar.currentAmount)) of \(formatter.string(from: jar.targetAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", jar.percentComplete * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(12)
        }
    }
    
    struct ProgressBar: View {
        var value: Double
        var color: Color
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.1)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        //.frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 8)
                        //.frame(minWidth: 380, minHeight: 350)
                        .foregroundColor(color)
                }
                .cornerRadius(4.0)
            }
            .frame(height: 8)
        }
    }
    
    struct TransactionRowView: View {
        let transaction: Transaction
        let formatter: CurrencyFormatter
        // Create a date formatter here instead of in the body
        private let dateFormatter = createDateFormatter()
        
        var body: some View {
            HStack {
                Image(systemName: transaction.isDeposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(transaction.isDeposit ? .green : .red)
                
                VStack(alignment: .leading) {
                    Text(transaction.isDeposit ? "Deposit" : "Withdrawal")
                        .font(.subheadline)
                    
                    Text(dateFormatter.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text((transaction.isDeposit ? "+" : "-") + formatter.string(from: abs(transaction.amount)))
                    .font(.subheadline)
                    .foregroundColor(transaction.isDeposit ? .green : .red)
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Detail View
    struct SavingsJarDetailView: View {
        let jar: SavingsJar
        @ObservedObject var viewModel: SavingsViewModel
        @State private var showingDeleteConfirmation = false
        @Environment(\.dismiss) private var dismiss
        
        var color: Color {
            viewModel.getColorFromString(jar.color)
        }
        
        var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 5) {
                        Text(jar.name)
                            .font(.fancyTitle)
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: jar.icon)
                                    .font(.system(size: 35))
                                    .foregroundColor(color)
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                    // Amount info
                    VStack(spacing: 8) {
                        Text(viewModel.formatter.string(from: jar.currentAmount))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                        
                        Text("of \(viewModel.formatter.string(from: jar.targetAmount)) goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressBar(value: jar.percentComplete, color: color)
                            .padding(.top, 5)
                        
                        Text(String(format: "%.1f%% Complete", jar.percentComplete * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        Button {
                            viewModel.showTransactionFor(jar: jar)
                        } label: {
                            Label("Deposit / Withdraw", systemImage: "arrow.left.arrow.right.circle.fill")
                                .frame(minWidth: 150)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    
                    // Transaction history
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Activity")
                            .font(.fancyHeading)
                        
                        if jar.transactions.isEmpty {
                            Text("No transactions yet")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            let sortedTransactions = jar.transactions.sorted { $0.date > $1.date }
                            
                            ForEach(sortedTransactions.prefix(10)) { transaction in
                                TransactionRowView(transaction: transaction, formatter: viewModel.formatter)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Delete Jar button
                    VStack {
                        Divider()
                            .padding(.vertical)
                        
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Label("Delete Jar", systemImage: "trash")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .alert("Delete Savings Jar", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteSavingsJar(with: jar.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(jar.name)\"? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Transaction Slider View
    struct TransactionSliderView: View {
        let jar: SavingsJar
        @ObservedObject var viewModel: SavingsViewModel
        @Binding var isVisible: Bool
        
        @State private var isDeposit = true
        @State private var sliderValue: Double = 0
        @State private var customAmount: String = ""
        @State private var useCustomAmount = false
        
        var maxAmount: Double {
            isDeposit ? 1000 : jar.currentAmount
        }
        
        var color: Color {
            viewModel.getColorFromString(jar.color)
        }
        
        var actionColor: Color {
            isDeposit ? .green : .red
        }
        
        var effectiveAmount: Double {
            if useCustomAmount, let amount = Double(customAmount), amount >= 0 {
                return min(amount, maxAmount)
            } else {
                return sliderValue
            }
        }
        
        var body: some View {
            VStack(spacing: 12) {
                // Header and Close Button
                HStack {
                    Text(jar.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        isVisible = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
                
                // Toggle between deposit and withdraw
                Picker("Transaction Type", selection: $isDeposit) {
                    Text("Deposit").tag(true)
                    Text("Withdraw").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: isDeposit) { newValue, oldValue in
                    // Reset slider value when changing modes
                    sliderValue = 0
                    customAmount = ""
                }
                
                // Toggle between slider and custom amount
                Toggle("Enter custom amount", isOn: $useCustomAmount)
                    .padding(.top, 3)
                
                if useCustomAmount {
                    // Custom amount input
                    HStack {
                        TextField("Amount", text: $customAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Max: \(viewModel.formatter.string(from: maxAmount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Slider for amount
                    VStack(spacing: 4) {
                        Slider(value: $sliderValue, in: 0...maxAmount)
                            .accentColor(actionColor)
                        
                        HStack {
                            Text("$0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(viewModel.formatter.string(from: maxAmount))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Display selected amount
                Text("\(isDeposit ? "Deposit" : "Withdraw") amount: \(viewModel.formatter.string(from: effectiveAmount))")
                    .font(.headline)
                    .foregroundColor(actionColor)
                    .padding(.vertical, 8)
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button("Cancel") {
                        isVisible = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button(isDeposit ? "Deposit" : "Withdraw") {
                        let amount = isDeposit ? effectiveAmount : -effectiveAmount
                        viewModel.updateSavingsJar(id: jar.id, amount: amount)
                        isVisible = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(actionColor)
                    .disabled(effectiveAmount <= 0)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Custom Add Jar View
    struct CustomAddJarView: View {
        @ObservedObject var viewModel: SavingsViewModel
        @Binding var isPresented: Bool
        
        @State private var name: String = ""
        @State private var targetAmount: String = ""
        @State private var selectedColor: String = "blue"
        @State private var selectedIcon: String = "banknote.fill"
        
        let colors = ["blue", "purple", "red", "green", "orange", "yellow"]
        let icons = ["banknote.fill", "dollarsign.circle.fill", "house.fill", "car.fill", "airplane", "gift.fill", "heart.circle", "star.fill"]
        
        var body: some View {VStack(spacing: 0) {
            // Blue title bar - now rendered with Color.View at the top
            Color.blue
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("New Savings Jar")
                            .font(.fancyTitle)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 14)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(20)
                        }
                    }
                        .padding(.horizontal)
                )
            
            // Add padding between title bar and form content
            Spacer()
                .frame(height: 16)
            
            // Form contents
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        TextField("Name", text: $name)
                            .textFieldStyle(.plain)
                            .padding()
                            .frame(height: 40)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(6)
                        
                        TextField("Target Amount", text: $targetAmount)
                            .textFieldStyle(.plain)
                            .padding()
                            .frame(height: 40)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(6)
                    }
                    .padding(.horizontal)
                    
                    Text("Color")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(viewModel.getColorFromString(color))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                        .padding(2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Icon")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(icons, id: \.self) { icon in
                            ZStack {
                                Circle()
                                    .fill(viewModel.getColorFromString(selectedColor).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 24))  // Explicit font size
                                    .foregroundColor(viewModel.getColorFromString(selectedColor))
                            }
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedIcon == icon ? 2 : 0)
                                    .padding(2)
                            )
                            .onTapGesture {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            if let target = Double(targetAmount), target > 0, !name.isEmpty {
                                let newJar = SavingsJar(
                                    name: name,
                                    targetAmount: target,
                                    currentAmount: 0,
                                    color: selectedColor,
                                    icon: selectedIcon
                                )
                                viewModel.addSavingsJar(newJar)
                                isPresented = false
                            }
                        }) {
                            Text("Add")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 60)
                                .background(
                                    Capsule()
                                        .fill(name.isEmpty || targetAmount.isEmpty ? Color.gray : Color.blue)
                                )
                        }
                        .disabled(name.isEmpty || targetAmount.isEmpty)
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(.windowBackgroundColor))
    }
}

// MARK: - App Entry Point
@main
struct SavingsJarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("")
        }
    }
}
}
