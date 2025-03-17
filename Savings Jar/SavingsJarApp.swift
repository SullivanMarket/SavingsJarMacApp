//
//  SavingsJarApp.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

// MARK: - Models
struct SavingsJar: Identifiable, Codable {
    var id = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var color: String // Store as string, convert to Color in the view
    var icon: String
    var creationDate = Date()
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
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

// MARK: - View Models
class SavingsViewModel: ObservableObject {
    @Published var savingsJars: [SavingsJar] = []
    let formatter = CurrencyFormatter.shared
    
    init() {
        loadSavingsJars()
    }
    
    func loadSavingsJars() {
        if let data = UserDefaults.standard.data(forKey: "savingsJars") {
            if let decoded = try? JSONDecoder().decode([SavingsJar].self, from: data) {
                self.savingsJars = decoded
                return
            }
        }
        
        // Add sample data if no saved jars
        self.savingsJars = [
            SavingsJar(name: "Vacation", targetAmount: 2000, currentAmount: 750, color: "blue", icon: "airplane"),
            SavingsJar(name: "New Phone", targetAmount: 1000, currentAmount: 350, color: "purple", icon: "iphone"),
            SavingsJar(name: "Emergency Fund", targetAmount: 5000, currentAmount: 2000, color: "red", icon: "heart.circle")
        ]
    }
    
    func saveSavingsJars() {
        if let encoded = try? JSONEncoder().encode(savingsJars) {
            UserDefaults.standard.set(encoded, forKey: "savingsJars")
        }
    }
    
    func addSavingsJar(_ jar: SavingsJar) {
        savingsJars.append(jar)
        saveSavingsJars()
    }
    
    func updateSavingsJar(id: UUID, amount: Double) {
        if let index = savingsJars.firstIndex(where: { $0.id == id }) {
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
}

// MARK: - Main Views
struct ContentView: View {
    @StateObject private var viewModel = SavingsViewModel()
    @State private var showingAddJar = false
    @State private var selectedJarId: UUID?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedJarId) {
                Section(header: Text("Summary")) {
                    NavigationLink(value: UUID()) {
                        Label("All Savings", systemImage: "dollarsign.circle.fill")
                    }
                }
                
                Section(header: Text("Savings Jars")) {
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
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteSavingsJar(at: indexSet)
                    }
                }
            }
            .navigationTitle("Savings Jars")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showingAddJar = true
                    }) {
                        Label("Add Jar", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let jarId = selectedJarId, jarId != UUID(), let jar = viewModel.savingsJars.first(where: { $0.id == jarId }) {
                SavingsJarDetailView(jar: jar, viewModel: viewModel)
            } else {
                // Overview screen
                SavingsOverviewView(savingsJars: viewModel.savingsJars)
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
        .animation(.easeInOut(duration: 0.3), value: showingAddJar)
    }
}

struct SavingsOverviewView: View {
    let savingsJars: [SavingsJar]
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
                    .font(.largeTitle)
                    .fontWeight(.bold)
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
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                // Grid of savings jars
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                    ForEach(savingsJars) { jar in
                        SavingsJarCard(jar: jar)
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
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(color)
            }
            .cornerRadius(4.0)
        }
        .frame(height: 8)
    }
}

// MARK: - Detail View
struct SavingsJarDetailView: View {
    let jar: SavingsJar
    @ObservedObject var viewModel: SavingsViewModel
    @State private var amountToAdd: String = ""
    @State private var amountToWithdraw: String = ""
    @State private var showingAddMoney = false
    @State private var showingWithdrawMoney = false
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
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
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
                    Button(action: {
                        showingAddMoney = true
                    }) {
                        Label("Add Money", systemImage: "plus.circle.fill")
                            .frame(minWidth: 120)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(color)
                    
                    Button(action: {
                        showingWithdrawMoney = true
                    }) {
                        Label("Withdraw", systemImage: "minus.circle.fill")
                            .frame(minWidth: 120)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Transaction history
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    ForEach(0..<3) { i in
                        HStack {
                            Image(systemName: i % 2 == 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                .foregroundColor(i % 2 == 0 ? .green : .red)
                            
                            VStack(alignment: .leading) {
                                Text(i % 2 == 0 ? "Deposit" : "Withdrawal")
                                    .font(.subheadline)
                                Text("Mar \(15 - i * 3), 2025")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            let amount = i % 2 == 0 ? (25.0 + Double(i * 10)) : (15.0 + Double(i * 5))
                            Text((i % 2 == 0 ? "+" : "-") + viewModel.formatter.string(from: amount))
                                .font(.subheadline)
                                .foregroundColor(i % 2 == 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor).opacity(0.3))
                        .cornerRadius(8)
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
        .popover(isPresented: $showingAddMoney) {
            VStack(spacing: 20) {
                Text("Add Money")
                    .font(.headline)
                
                TextField("Amount", text: $amountToAdd)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Cancel") {
                        amountToAdd = ""
                        showingAddMoney = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Add") {
                        if let amount = Double(amountToAdd), amount > 0 {
                            viewModel.updateSavingsJar(id: jar.id, amount: amount)
                        }
                        amountToAdd = ""
                        showingAddMoney = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(color)
                }
            }
            .padding()
            .frame(width: 300)
        }
        .popover(isPresented: $showingWithdrawMoney) {
            VStack(spacing: 20) {
                Text("Withdraw Money")
                    .font(.headline)
                
                TextField("Amount", text: $amountToWithdraw)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Cancel") {
                        amountToWithdraw = ""
                        showingWithdrawMoney = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Withdraw") {
                        if let amount = Double(amountToWithdraw), amount > 0, amount <= jar.currentAmount {
                            viewModel.updateSavingsJar(id: jar.id, amount: -amount)
                        }
                        amountToWithdraw = ""
                        showingWithdrawMoney = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                }
            }
            .padding()
            .frame(width: 300)
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Blue title bar - now rendered with Color.View at the top
            Color.blue
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("New Savings Jar")
                            .font(.headline)
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
        }
    }
}
