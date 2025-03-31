//
//  EditJarView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/29/25.
//

import SwiftUI

struct EditJarView: View {
    @ObservedObject var viewModel: SavingsViewModel
    let jar: SavingsJar
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var targetAmount: String
    @State private var selectedColor: String
    @State private var selectedIcon: String
    
    let colors = ["blue", "purple", "red", "green", "orange", "yellow"]
    let icons = ["banknote.fill", "dollarsign.circle.fill", "house.fill", "car.fill", "airplane", "gift.fill", "heart.circle", "star.fill", "briefcase.fill", "graduationcap.fill", "cart.fill", "cross.fill", "book.fill", "desktopcomputer", "gamecontroller.fill", "tray.fill", "creditcard.fill", "bag.fill", "leaf.fill", "building.fill"]

    init(viewModel: SavingsViewModel, jar: SavingsJar, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.jar = jar
        self._isPresented = isPresented
        self._name = State(initialValue: jar.name)
        self._targetAmount = State(initialValue: "\(jar.targetAmount)")
        self._selectedColor = State(initialValue: jar.color)
        self._selectedIcon = State(initialValue: jar.icon)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar with blue background - positioned at the top edge
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .overlay(
                    Text("Edit Savings Jar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Content - Not scrollable as a whole
            VStack(spacing: 15) {
                // Name field
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 15)
                
                // Target amount field
                TextField("Target Amount", text: $targetAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidChangeNotification)) { _ in
                        targetAmount = targetAmount.filter { "0123456789.".contains($0) }
                    }
                
                // Color selection
                VStack(alignment: .center, spacing: 8) {
                    Text("Color")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(getColor(color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: selectedColor == color ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Icon selection - Only this part is scrollable
                VStack(alignment: .center, spacing: 8) {
                    Text("Icon")
                        .font(.headline)
                    
                    // Scrollable icon grid with fixed height
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 240) // Reduced height to make room for buttons
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20) // This ensures there's space for the buttons
                
                // Action buttons at the bottom of the content area
                HStack(spacing: 20) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(Color.red))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        saveChanges()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                    .opacity(name.isEmpty || targetAmount.isEmpty ? 0.7 : 1.0)
                }
                .padding(.horizontal)
                .padding(.bottom, 20) // Add padding below the buttons
            }
            .padding(.vertical, 0) // Remove vertical padding to ensure blue bar stays at top
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .frame(width: 400, height: 600)
        .clipped() // This ensures content doesn't overflow the frame
    }
    
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
    
    private func saveChanges() {
        guard let target = Double(targetAmount), target > 0 else {
            return
        }
        
        let updatedJar = SavingsJar(
            id: jar.id,
            name: name,
            targetAmount: target,
            currentAmount: jar.currentAmount,
            color: selectedColor,
            icon: selectedIcon,
            creationDate: jar.creationDate,
            transactions: jar.transactions
        )
        
        viewModel.updateSavingsJar(updatedJar: updatedJar)
        isPresented = false
    }
}
