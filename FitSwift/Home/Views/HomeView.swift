//
//  HomeView.swift
//  FitSwift
//
//  Created by csuftitan on 4/7/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Add the profile banner at the top
                    ProfileBannerView(userName: viewModel.userName, profileImage: "person.crop.circle.fill")
                        .padding(.top)
                    
                    // Activity rings section
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calories")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.fitSwiftRed)
                                Text("\(viewModel.calories)")
                                    .font(.caption)
                                    .bold()
                            }.padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Activities")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.fitSwiftGreen)
                                Text("\(viewModel.exercise)")
                                    .font(.caption)
                                    .bold()
                            }.padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stand")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.cyan)
                                Text("\(viewModel.stand)")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        
                        Spacer()
                        ZStack {
                            ProgressCircleView(progress: $viewModel.calories, color: .red, goal: 600)
                            ProgressCircleView(progress: $viewModel.exercise, color: .green, goal: 60)
                                .padding(.all, 20)
                            ProgressCircleView(progress: $viewModel.stand, color: .cyan, goal: 20)
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
                    if !viewModel.activities.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing:20), count: 2)) {
                            ForEach(viewModel.activities, id: \.title) { activity in
                                ActivityCard(activity: activity)
                            }
                        }.padding(.horizontal)
                    }
                    
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
                        ForEach(viewModel.workouts, id: \.self) { workout in
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
