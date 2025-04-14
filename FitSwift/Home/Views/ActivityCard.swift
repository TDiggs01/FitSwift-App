//
//  ActivityCard.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import SwiftUI
    
struct ActivityCard: View {
    @State var activity: Activity
    
    var body: some View {
        
        
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)
                        
                        Text(activity.subTitle)
                            .font(.caption)
                    }
                    Spacer()
                                    
                    Image(systemName: activity.image)
                        .foregroundColor(activity.tinColor)
                }
                
                Text(activity.amount)
                    .font(.title)
                    .bold(true)
                    .padding()
                
            }.padding()
            
        }
    }
}


#Preview {
    ActivityCard(activity: Activity(id: 0, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .green, amount: "6,000"))
}
