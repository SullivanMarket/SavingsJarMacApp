//
//  AboutPopupView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/30/25.
//

import SwiftUI

struct AboutPopupView: View {
    @Binding var isPresented: Bool
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        VStack(spacing: 0) {
            // Blue header with text properly aligned
            Rectangle()
                .fill(Color.blue)
                .frame(height: 75)
                .overlay(
                    Text("About Savings Jar")
                        .font(.title)
                        .bold()
                        .italic()
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .padding(.top, 10),
                    alignment: .topLeading
                )
            
            VStack(spacing: 20) {
                // App icon with fallback approach for macOS
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 150, height: 150)
                    
                    // Try to use a system image
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                }
                
                // App name and version
                Text("Savings Jar")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Description
                Text("A simple and effective tool to track your savings goal...")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                // Copyright
                Text("© 2025 Sean Sullivan. All rights reserved.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer()
                
                // Close button
                Button {
                    isPresented = false
                } label: {
                    Text("Close")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 45)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 40)
            }
            .padding(.top, 35)
        }
        .frame(width: 400, height: 600)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }
}
