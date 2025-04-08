//
//  ProgressBar.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
//import Savings_Jar

struct ProgressBar: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(max(0, min(1, progress))), height: geometry.size.height)
                    .foregroundColor(color)
            }
            .cornerRadius(3)
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBar(progress: 0.3, color: .blue)
                .frame(height: 10)
                .padding()
            
            ProgressBar(progress: 0.7, color: .green)
                .frame(height: 10)
                .padding()
            
            ProgressBar(progress: 1.0, color: .purple)
                .frame(height: 10)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
