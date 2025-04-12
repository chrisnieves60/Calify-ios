//
//  LoadingView.swift
//  mine
//
//  Created by christopher on 4/5/25.
//

import Foundation
import SwiftUI

struct LoadingView: View {//TODO: Familiarize yourself with these design quirks. 
    @State private var isAnimating = false //obvious, isAnimating state
    
    var body: some View {
        ZStack { //im unfamiliar with a zstack, research?
            Circle()//circles, strokes, frames, all design things im fully unfamiliar with.
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.blue, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
        }
        .padding()
    }
}
