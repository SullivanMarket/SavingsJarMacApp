//
//  CustomAddJarView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct CustomAddJarView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var selectedColor: String
    @State private var selectedIcon: String = "banknote.fill"
    
    // Original color array - these are known to work with the existing getColorFromString method
    let colors = ["blue", "purple", "red", "green", "orange", "yellow"]
    
    // Keep your original icons array with additional icons added
    let icons = ["banknote.fill", "dollarsign.circle.fill", "house.fill", "car.fill", "airplane", "gift.fill", "heart.circle", "star.fill",
        // Add additional icons directly to this array
        "graduationcap.fill", "book.fill", "desktopcomputer", "laptopcomputer",
        "beach.umbrella.fill", "tent.fill", "mountain.2.fill", "map.fill",
        "cross.fill", "heart.text.square.fill", "fork.knife", "cart.fill",
        "camera.fill", "sportscourt.fill", "bolt.fill", "flame.fill",
        "person.3.fill", "birthday.cake.fill", "figure.dress.line.vertical.figure",
        "chart.line.uptrend.xyaxis", "creditcard.fill", "clock.fill", "key.fill", "globe",
        // New additional icons
        "plus", "plus.circle.fill", "minus", "minus.circle.fill",
        "checkmark.circle.fill", "xmark.circle.fill", "exclamationmark.circle.fill",
        "info.circle.fill", "questionmark.circle.fill", "phone.fill",
        "envelope.fill", "bag.fill", "tag.fill",
        "hammer.fill", "wrench.fill", "screwdriver.fill", "paintbrush.fill",
        "folder.fill", "doc.fill", "calendar", "bell.fill",
        "moon.fill", "sun.max.fill", "cloud.fill", "cloud.rain.fill",
        "snowflake", "drop.fill", "battery.100",
        "wifi", "antenna.radiowaves.left.and.right", "lock.fill", "shield.fill",
        "externaldrive.fill", "archivebox.fill", "trash.fill", "crown.fill",
        "music.note", "headphones", "gamecontroller.fill", "iphone"]
    
    // Use custom initializer to set up default values from settings
    init(viewModel: SavingsViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        
        // Initialize state variable with a default value
        // The actual setting will be applied in onAppear
        self._selectedColor = State(initialValue: "blue")
        self._targetAmount = State(initialValue: "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            ZStack {
                // Background
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 60)
                
                // Title - changed to "New Savings Jar" and added top padding
                Text("New Savings Jar")
                    .font(.fancyTitle)
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
            
            // Form content in a compact layout
            VStack(spacing: 16) {
                // Name field - centered
                VStack(alignment: .center, spacing: 4) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Centered text field
                    HStack {
                        Spacer()
                        TextField("Name", text: $name)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .multilineTextAlignment(.center)
                            .frame(height: 32)
                            .frame(width: 250)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(6)
                        Spacer()
                    }
                }
                .padding(.top, 20)
                
                // Target Amount field - centered
                VStack(alignment: .center, spacing: 4) {
                    Text("Target Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Centered text field
                    HStack {
                        Spacer()
                        TextField("Target Amount", text: $targetAmount)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .multilineTextAlignment(.center)
                            .frame(height: 32)
                            .frame(width: 250)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(6)
                        Spacer()
                    }
                }
                
                // Colors section - centered
                VStack(alignment: .center, spacing: 4) {
                    Text("Color")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                    
                    // Scrollable color grid limited to 2 rows height
                    ScrollView(showsIndicators: true) {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6),
                            spacing: 12
                        ) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(viewModel.getColorFromString(color))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                            .padding(1)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    // Set explicit height for 2 rows: (2 * circle height) + spacing + padding
                    .frame(maxHeight: 90, alignment: .top)
                }
                .padding(.top, 10)
                
                // Icons section - with ScrollView
                VStack(alignment: .leading, spacing: 4) {
                    Text("Icon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 25)
                    
                    // Added ScrollView around just the LazyVGrid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                            ForEach(icons, id: \.self) { icon in
                                ZStack {
                                    Circle()
                                        .fill(viewModel.getColorFromString(selectedColor).opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(viewModel.getColorFromString(selectedColor))
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedIcon == icon ? 2 : 0)
                                        .padding(1)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .frame(height: 170) // Fixed height for ScrollView to contain icons
                }
                
                Spacer()
                
                // Buttons at bottom with no borders
                HStack(spacing: 20) {
                    // Cancel button - direct ZStack approach
                    ZStack {
                        // Pill shape
                        Capsule()
                            .fill(Color.red)
                            .frame(width: 140, height: 40)
                        
                        // Button text
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .onTapGesture {
                        isPresented = false
                    }
                    
                    // Add button - direct ZStack approach
                    ZStack {
                        // Pill shape
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: 140, height: 40)
                        
                        // Button text
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .onTapGesture {
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
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                    .opacity(name.isEmpty || targetAmount.isEmpty ? 0.5 : 1.0)
                }
                .padding(.bottom, 25)
                .background(Color(.windowBackgroundColor))
            }
        }
        .frame(width: 580, height: 580)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            // Set default values from settings when the view appears
            selectedColor = settingsManager.settings.defaultColor
            targetAmount = String(format: "%.0f", settingsManager.settings.defaultTarget)
        }
    }
}
