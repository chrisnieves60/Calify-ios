//
//  ScoreGuageView.swift
//  mine
//
//  Created by christopher on 4/12/25.
//

import Foundation
import SwiftUI

// Semi-circular gauge component TODO: Fully comprehend these components... important for swift ui learning.
struct ScoreGaugeView: View {
    let score: Int
    let title: String
    let description: String
    
    // Get color based on score
    private var color: Color {
        switch score {
        case 0..<40: return .red
        case 40..<70: return .orange
        default: return .green
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background track
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(180))
                
                // Colored progress
                Circle()
                    .trim(from: 0, to: CGFloat(min(Double(score) / 200.0, 0.5)))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(180))
                
                VStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(score)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
}
