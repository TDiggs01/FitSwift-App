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
    
    var mockActivities = [Activity(id: 0, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .green, amount: "6,000"),
        Activity(id: 1, title: "Today Steps", subTitle: "Goal: 1,000 steps", image: "figure.walk", tinColor: .red, amount: "678"),
        Activity(id: 2, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .blue, amount: "9,812"),
        Activity(id: 3, title: "Today Steps", subTitle: "Goal: 50,000 steps", image: "figure.run", tinColor: .purple, amount: "19,000")
    ]
    
    var mockWorkouts = [
        Workout(id: 0, title: "Running", image: "figure.run", tinColor: .green, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
        Workout(id: 2, title: "Strength  Training", image: "figure.run", tinColor: .red, duration: "5 mins", date: "Apirl 4", calories: "512 Kcal"),
        Workout(id: 3, title: "Swimming", image: "figure.run", tinColor: .blue, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
        Workout(id: 4, title: "Running", image: "figure.run", tinColor: .purple, duration: "1 mins", date: "Apirl 1", calories: "512 Kcal")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .padding()
                    
                    HStack {
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
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
                                    .foregroundColor(.cyan)
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
                            ProgressCircleView(progress: $stand, color: .cyan, goal: 20)
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
                            Text("Show more")
                                .padding(.all, 10)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(20)
                        }.padding(.horizontal)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(spacing:20), count: 2)) {
                        ForEach(mockActivities, id: \.id) { activity in
                            ActivityCard(activity: activity)
                        }
                    }.padding(.horizontal)
                    
                    HStack {
                        Text("Recent Workouts")
                            .padding(.horizontal)
                            .font(.title2)
                        
                        Spacer()
                        
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Text("Show more")
                                .padding(.all, 10)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(20)
                        }.padding(.horizontal)
                        
                    }.padding(.horizontal)
                        .padding(.top)
                    
                    LazyVStack {
                        ForEach(mockWorkouts, id: \.id) { workout in
                            WorkoutCard(workout: workout)
                        }
                    }
                    
                }
            }
        }
    }
}


#Preview {
    HomeView()
}
