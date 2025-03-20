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
    
    let colors = ["blue", "purple", "red", "green", "orange", "yellow"]
    let icons = ["banknote.fill", "dollarsign.circle.fill", "house.fill", "car.fill", "airplane", "gift.fill", "heart.circle", "star.fill"]
    
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
            // Blue title bar
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
        .onAppear {
            // Set default values from settings when the view appears
            selectedColor = settingsManager.settings.defaultColor
            targetAmount = String(format: "%.0f", settingsManager.settings.defaultTarget)
        }
    }
}
