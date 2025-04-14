//
//  ProgressCircleView.swift
//  FitSwift
//
//  Created by csuftitan on 4/7/25.
//

import SwiftUI

struct ProgressCircleView: View {
    
    @Binding var progress: Int
    var color: Color
    var goal: Int
    private let width: CGFloat = 20

    var body: some View {
        
        ZStack {
            // Inner Circle
            Circle().stroke(color.opacity(0.3), lineWidth: width)
            // Outer Circle
            Circle().trim(from: 0, to: CGFloat(Double(progress) / Double(goal)) )
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
        }.padding()
    }
}

#Preview {
    ProgressCircleView(progress: .constant(100), color: .red, goal: 200)
}
