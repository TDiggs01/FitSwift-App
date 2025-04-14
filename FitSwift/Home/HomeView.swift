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
    
    var mockActivities = [Activity(id: 0, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .green, amount: "6,000"), Activity(id: 1, title: "Today Steps", subTitle: "Goal: 1,000 steps", image: "figure.walk", tinColor: .red, amount: "678"), Activity(id: 2, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .blue, amount: "9,812"), Activity(id: 3, title: "Today Steps", subTitle: "Goal: 50,000 steps", image: "figure.run", tinColor: .purple, amount: "19,000")]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
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
                    }.padding(.horizontal)
                    
                    Spacer()
                }.padding(.horizontal)
                
                HStack {
                    Text("Today Activity")
                        .padding(.horizontal)
                        .font(.title2)
                    
                    Spacer()
                    
                    Button {
                        print("Show More")
                    } label: {
                        Text("Show More")
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.all, 10)
                            .fontWeight(.medium)
                    }.padding(.horizontal)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(spacing:20), count: 2)) {
                    ForEach(mockActivities, id: \.id) { activity in
                        ActivityCard(activity: activity)
                    }
                }.padding(.horizontal)
                
            }
        }
    }
}


#Preview {
    HomeView()
}
