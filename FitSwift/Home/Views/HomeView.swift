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

                    // Today Activity section with add/edit buttons
                    HStack {
                        Text("Today Activity")
                            .font(.title2)

                        Spacer()

                        // Edit button
                        Button {
                            viewModel.toggleEditMode()
                        } label: {
                            Text(viewModel.isEditMode ? "Done" : "Edit")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(viewModel.isEditMode ? .white : .blue)
                                .background(viewModel.isEditMode ? Color.blue : Color.clear)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(viewModel.isEditMode ? Color.clear : Color.blue, lineWidth: 1)
                                )
                        }

                        // Add button
                        Button {
                            viewModel.showingAddActivitySheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)

                    if !viewModel.activities.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing:20), count: 2)) {
                            ForEach(viewModel.activities, id: \.title) { activity in
                                ActivityCard(
                                    activity: activity,
                                    isEditMode: viewModel.isEditMode,
                                    onDelete: {
                                        viewModel.removeActivity(activity)
                                    }
                                )
                            }
                        }.padding(.horizontal)
                    } else {
                        Text("No activities yet. Tap the + button to add one.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }

                    // Recent Workouts section with add/edit buttons
                    HStack {
                        Text("Recent Workouts")
                            .font(.title2)

                        Spacer()

                        // Add workout button
                        Button {
                            viewModel.showingAddWorkoutSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }

                        NavigationLink {
                            WorkoutListView()
                        } label: {
                            Text("Show more")
                                .padding(.all, 10)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    if !viewModel.workouts.isEmpty {
                        LazyVStack {
                            ForEach(viewModel.workouts, id: \.self) { workout in
                                WorkoutCard(
                                    workout: workout,
                                    isEditMode: viewModel.isEditMode,
                                    onDelete: {
                                        viewModel.removeWorkout(workout)
                                    }
                                )
                            }
                        }
                    } else {
                        Text("No workouts yet. Tap the + button to add one.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .navigationTitle("FitSwift")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingAddActivitySheet) {
                AddActivityView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingAddWorkoutSheet) {
                AddWorkoutView(viewModel: viewModel)
            }
        }
    }
}


#Preview {
    HomeView()
}
