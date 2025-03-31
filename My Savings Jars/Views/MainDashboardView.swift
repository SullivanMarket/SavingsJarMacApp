//
//  MainDashboardView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/29/25.
//

import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @ObservedObject var settingsManager: SettingsManager
    
    // State for showing popups
    @State private var showingSettingsPopup = false
    @State private var showingAddJarPopup = false
    @State private var showingAboutPopup = false
    @State private var showingExportPopup = false
    @State private var showingImportPopup = false
    @State private var showingTransactionsPopup = false
    @State private var sidebarExpanded = true
    @State private var selectedJarIndex: Int? = nil
    @State private var showMenu = false
    
    // Formatter for currency
    let formatter = CurrencyFormatter.shared
    
    // Computed properties for totals
    var totalSaved: Double {
        viewModel.savingsJars.reduce(0) { $0 + $1.currentAmount }
    }
    
    var totalTarget: Double {
        viewModel.savingsJars.reduce(0) { $0 + $1.targetAmount }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // SIDEBAR
            if sidebarExpanded {
                ZStack(alignment: .top) {
                    // Background color for the entire sidebar
                    VStack(spacing: 0) {
                        // Top header area with controls
                        Rectangle()
                            .fill(Color(red: 0.4, green: 0.4, blue: 0.8))
                            .frame(height: 60)
                        
                        // Light blue background that extends down the entire sidebar
                        Rectangle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(maxHeight: .infinity)
                    }
                    
                    // Content overlaid on the colored backgrounds
                    VStack(spacing: 0) {
                        // Top section with controls
                        HStack {
                            // Hamburger menu with left padding
                            Button(action: {
                                showMenu.toggle()
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Circle().fill(Color.white.opacity(0.2)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading, 16)
                            .popover(isPresented: $showMenu, arrowEdge: .bottom) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Button(action: {
                                        showingAddJarPopup = true
                                        showMenu = false
                                    }) {
                                        Label("Add New Jar", systemImage: "plus.circle")
                                            .foregroundColor(.primary)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .frame(width: 200, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        showingSettingsPopup = true
                                        showMenu = false
                                    }) {
                                        Label("Settings", systemImage: "gear")
                                            .foregroundColor(.primary)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .frame(width: 200, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        showingExportPopup = true
                                        showMenu = false
                                    }) {
                                        Label("Export Jars", systemImage: "square.and.arrow.up")
                                            .foregroundColor(.primary)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .frame(width: 200, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        showingImportPopup = true
                                        showMenu = false
                                    }) {
                                        Label("Import Jars", systemImage: "square.and.arrow.down")
                                            .foregroundColor(.primary)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .frame(width: 200, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        showingAboutPopup = true
                                        showMenu = false
                                    }) {
                                        Label("About", systemImage: "info.circle")
                                            .foregroundColor(.primary)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .frame(width: 200, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 8)
                                .background(Color(.windowBackgroundColor))
                                .cornerRadius(12)
                            }
                            
                            Spacer()
                            
                            // Expand/collapse button
                            Button(action: {
                                withAnimation {
                                    sidebarExpanded.toggle()
                                }
                            }) {
                                Image(systemName: "sidebar.left")
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Circle().fill(Color.white.opacity(0.2)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical)
                        .frame(height: 60)
                        
                        // All Savings option
                        Button(action: {
                            selectedJarIndex = nil
                        }) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                Text("All Savings")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(formatter.string(from: totalSaved))
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .background(selectedJarIndex == nil ? Color.blue.opacity(0.2) : Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // List of Savings Jars
                        ScrollView {
                            LazyVStack(spacing: 2) {
                                ForEach(Array(viewModel.savingsJars.enumerated()), id: \.element.id) { index, jar in
                                    Button(action: {
                                        selectedJarIndex = index
                                    }) {
                                        HStack {
                                            Image(systemName: jar.icon)
                                                .foregroundColor(getColor(jar.color))
                                                .frame(width: 24)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(jar.name)
                                                    .font(.headline)
                                                
                                                Text("\(formatter.string(from: jar.currentAmount)) / \(formatter.string(from: jar.targetAmount))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(String(format: "%.1f%%", jar.percentComplete * 100))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(selectedJarIndex == index ? Color.gray.opacity(0.1) : Color.clear)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
                .frame(width: 260)
                .background(Color(.windowBackgroundColor))
            }
            
            // MAIN CONTENT AREA
            VStack(spacing: 0) {
                // Header and controls
                HStack {
                    Text("Total Savings")
                        .font(.title)
                        .bold()
                        .italic()
                    
                    Spacer()
                    
                    if !sidebarExpanded {
                        Button(action: {
                            withAnimation {
                                sidebarExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "sidebar.right")
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 32)
                                .background(Color.clear) // Transparent button
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                // Always show total savings overview
                totalSavingsOverview
                
                Divider()
                
                // Bottom section based on selection
                if let selectedIndex = selectedJarIndex, selectedIndex < viewModel.savingsJars.count {
                    // Selected jar header and details
                    VStack(spacing: 0) {
                        selectedJarHeader(viewModel.savingsJars[selectedIndex])
                        
                        Divider()
                        
                        selectedJarDetails(viewModel.savingsJars[selectedIndex])
                    }
                } else {
                    // All jars grid
                    allJarsGrid
                }
            }
        }
        // POPUPS
        .sheet(isPresented: $showingSettingsPopup) {
            SettingsView(settingsManager: settingsManager, isPresented: $showingSettingsPopup)
                .frame(width: 480, height: 600)
        }
        .sheet(isPresented: $showingAddJarPopup) {
            CustomAddJarView(viewModel: viewModel, isPresented: $showingAddJarPopup)
                .frame(width: 400, height: 600)
        }
        .sheet(isPresented: $viewModel.showingTransactionPopup) {
            if let jar = viewModel.selectedJarForTransaction {
                TransactionSliderView(viewModel: viewModel, jar: jar, isPresented: $viewModel.showingTransactionPopup)
                    .frame(width: 400, height: 550)
            }
        }
        .sheet(isPresented: $viewModel.showingEditJarPopup) {
            if let jar = viewModel.selectedJarForEditing {
                EditJarView(viewModel: viewModel, jar: jar, isPresented: $viewModel.showingEditJarPopup)
                    .frame(width: 400, height: 600)
            }
        }
        .sheet(isPresented: $showingTransactionsPopup) {
            if let selectedIndex = selectedJarIndex, selectedIndex < viewModel.savingsJars.count {
                TransactionsListView(viewModel: viewModel, jar: viewModel.savingsJars[selectedIndex], isPresented: $showingTransactionsPopup)
                    .frame(width: 500, height: 650)
            }
        }
        // New popup sheets for Export, Import, and About
        .sheet(isPresented: $showingExportPopup) {
            ExportJarsView(viewModel: viewModel, isPresented: $showingExportPopup)
        }
        .sheet(isPresented: $showingImportPopup) {
            ImportJarsView(viewModel: viewModel, isPresented: $showingImportPopup)
        }
        .sheet(isPresented: $showingAboutPopup) {
            AboutPopupView(isPresented: $showingAboutPopup)
        }
    }
    
    // SELECTED JAR HEADER VIEW
    private func selectedJarHeader(_ jar: SavingsJar) -> some View {
        HStack {
            Image(systemName: jar.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(getColor(jar.color))
            
            VStack(alignment: .leading) {
                Text(jar.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Created \(jar.creationDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.windowBackgroundColor))
    }
    
    // TOTAL SAVINGS OVERVIEW
    private var totalSavingsOverview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Progress")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.2))
                                .frame(height: 20)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(min(1, totalSaved / totalTarget)), height: 20)
                        }
                    }
                    .frame(height: 20)
                    
                    HStack {
                        Text("\(formatter.string(from: totalSaved)) of \(formatter.string(from: totalTarget))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", totalTarget > 0 ? (totalSaved / totalTarget * 100) : 0))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(formatter.string(from: totalSaved))
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.windowBackgroundColor))
    }
    
    // SELECTED JAR DETAILS
    private func selectedJarDetails(_ jar: SavingsJar) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(getColor(jar.color).opacity(0.2))
                                .frame(height: 20)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(getColor(jar.color))
                                .frame(width: geometry.size.width * CGFloat(jar.percentComplete), height: 20)
                        }
                    }
                    .frame(height: 20)
                    
                    HStack {
                        Text(formatter.string(from: jar.currentAmount))
                        Spacer()
                        Text("$\(jar.targetAmount, specifier: "%.2f")")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(12)
                
                // Action Buttons - Updated for full area clickability
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.selectedJarForTransaction = jar
                        viewModel.showingTransactionPopup = true
                    }) {
                        Text("Deposit / Withdraw")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        viewModel.selectedJarForEditing = jar
                        viewModel.showingEditJarPopup = true
                    }) {
                        Text("Edit Jar")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Show delete confirmation
                        if let index = viewModel.savingsJars.firstIndex(where: { $0.id == jar.id }) {
                            viewModel.deleteSavingsJar(at: IndexSet(integer: index))
                            selectedJarIndex = nil
                        }
                    }) {
                        Text("Delete Jar")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.red))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // View Transactions Button - Changed to solid blue with white text
                Button(action: {
                    showingTransactionsPopup = true
                }) {
                    Text("View Transactions")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Recent Transactions Preview
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                    
                    if jar.transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    } else {
                        ForEach(jar.transactions.prefix(5)) { transaction in
                            HStack {
                                Image(systemName: transaction.amount > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .foregroundColor(transaction.amount > 0 ? .green : .red)
                                
                                Text(transaction.date, style: .date)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(formatter.string(from: abs(transaction.amount)))
                                    .fontWeight(.medium)
                                    .foregroundColor(transaction.amount > 0 ? .green : .red)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // ALL JARS GRID
    private var allJarsGrid: some View {
        ScrollView {
            Text("All Savings Jars")
                .font(.title2)
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                ForEach(viewModel.savingsJars) { jar in
                    VStack(alignment: .leading, spacing: 16) {
                        // Top row: Icon on left, jar name to the right of the icon
                        HStack(alignment: .center) {
                            // Jar Icon
                            Image(systemName: jar.icon)
                                .foregroundColor(getColor(jar.color))
                                .font(.title2)
                                .frame(width: 30, height: 30)
                            
                            // Jar Name (Title) - positioned right next to the icon
                            Text(jar.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black) // Explicitly set to black
                            
                            Spacer()
                        }
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(getColor(jar.color).opacity(0.2))
                                    .frame(height: 20)
                                
                                // Progress
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(getColor(jar.color))
                                    .frame(width: max(4, geometry.size.width * CGFloat(jar.percentComplete)), height: 20)
                            }
                        }
                        .frame(height: 20)
                        
                        // Amount row - balance/goal on left, percentage on right
                        HStack {
                            // Balance/Goal on left
                            Text("\(formatter.string(from: jar.currentAmount)) / \(formatter.string(from: jar.targetAmount))")
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.black) // Explicitly set to black
                            
                            Spacer()
                            
                            // Percentage on the right
                            Text(String(format: "%.1f%%", jar.percentComplete * 100))
                                .font(.subheadline)
                                .foregroundColor(getColor(jar.color))
                                .fontWeight(.semibold)
                        }
                        
                        // View Button
                        Button(action: {
                            // Find and select this jar to show details
                            if let index = viewModel.savingsJars.firstIndex(where: { $0.id == jar.id }) {
                                selectedJarIndex = index
                            }
                        }) {
                            Text("View")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(getColor(jar.color)))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
    }
    
    // Helper method to get color
    private func getColor(_ colorString: String) -> Color {
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
}

// TRANSACTIONS LIST VIEW
struct TransactionsListView: View {
    @ObservedObject var viewModel: SavingsViewModel
    let jar: SavingsJar
    @Binding var isPresented: Bool
    
    let formatter = CurrencyFormatter.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar with bigger text
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60) // Taller header
                .overlay(
                    Text("\(jar.name) Transactions")
                        .font(.title2) // Bigger font
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Content
            VStack(spacing: 16) {
                // Jar summary
                HStack {
                    Image(systemName: jar.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(getColor(jar.color))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(jar.name)
                            .font(.headline)
                        
                        Text("Current Balance: \(formatter.string(from: jar.currentAmount))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.selectedJarForTransaction = jar
                        viewModel.showingTransactionPopup = true
                        isPresented = false
                    }) {
                        Text("New Transaction")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Divider()
                
                // Transactions list
                if jar.transactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Transactions Yet")
                            .font(.headline)
                        
                        Text("Add a deposit or withdrawal to get started")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(jar.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        // Transaction icon and type indicator
                                        ZStack {
                                            // Colored background circle
                                            Circle()
                                                .fill(transaction.amount > 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            
                                            // Directional arrow icon
                                            Image(systemName: transaction.amount > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                                .foregroundColor(transaction.amount > 0 ? .green : .red)
                                        }
                                        
                                        // Transaction details
                                        VStack(alignment: .leading, spacing: 4) {
                                            // Transaction type text
                                            Text(transaction.amount > 0 ? "Deposit" : "Withdrawal")
                                                .font(.headline)
                                            
                                            // Transaction date
                                            Text(transaction.date, style: .date)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                        
                                        Spacer()
                                        
                                        // Transaction amount
                                        Text(formatter.string(from: abs(transaction.amount)))
                                            .font(.headline)
                                            .foregroundColor(transaction.amount > 0 ? .green : .red)
                                    }
                                    
                                    // Transaction note
                                    if !transaction.note.isEmpty {
                                        Text(transaction.note)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 65)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Close button - Updated for full area clickability
                Button(action: {
                    isPresented = false
                }) {
                    Text("Close")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 20) // More bottom padding
            }
            .padding(.vertical)
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        // Specific size to ensure no cutoff
        .frame(width: 500, height: 650)
    }
    
    // Helper method to get color
    private func getColor(_ colorString: String) -> Color {
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
}

struct MainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        let settingsManager = SettingsManager()
        return MainDashboardView(viewModel: viewModel, settingsManager: settingsManager)
    }
}
