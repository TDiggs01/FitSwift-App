//
//  HomeView.swift
//  FitSwift
//
//  Created by csuftitan on 4/7/25.
//

import SwiftUI

struct HomeView: View {
    
    @State var calories: Int = 123
    @State var active: Int = 52
    @State var stand: Int = 8
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
                
                HStack {
                    
                    Spacer()
                    
                    VStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.fitSwiftRed)
                            Text("123 kcal")
                                .font(.caption)
                                .bold()
                        }.padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activities")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.fitSwiftGreen)
                            Text("1 min")
                                .font(.caption)
                                .bold()
                        }.padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stand")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.fitSwiftLightGray)
                            Text("8 hours")
                                .font(.caption)
                                .bold()
                        }
                    }
                    
                    Spacer()
                    ZStack {
                        ProgressCircleView(progress: $calories, color: .red, goal: 600)
                        ProgressCircleView(progress: $active, color: .green, goal: 60)
                            .padding(.all, 20)
                        ProgressCircleView(progress: $stand, color: .fitSwiftLightGray, goal: 20)
                            .padding(.all, 40)
                    }
                    
                }
            }
        }
    }
}


#Preview {
    HomeView()
}
