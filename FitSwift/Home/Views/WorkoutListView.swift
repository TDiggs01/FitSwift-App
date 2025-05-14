//
//  WorkoutListView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import SwiftUI

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutListViewModel()
    @State private var selectedFilter: WorkoutFilter = .all
    @State private var searchText = ""

    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search workouts", text: $searchText)
                    .onChange(of: searchText) {
                        viewModel.filterWorkouts(by: selectedFilter, searchText: searchText)
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        viewModel.filterWorkouts(by: selectedFilter, searchText: "")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(WorkoutFilter.allCases, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                            viewModel.filterWorkouts(by: filter, searchText: searchText)
                        } label: {
                            Text(filter.displayName)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedFilter == filter ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 5)

            // Workout list
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            } else if viewModel.filteredWorkouts.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)

                    Text("No workouts found")
                        .font(.headline)

                    Text("Try adjusting your filters or search criteria")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                List {
                    ForEach(viewModel.filteredWorkouts, id: \.self) { workout in
                        WorkoutCard(workout: workout)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Workout History")
        .onAppear {
            viewModel.loadWorkouts()
        }
    }
}

// Workout filter options
enum WorkoutFilter: String, CaseIterable {
    case all
    case running
    case strength
    case swimming
    case cycling
    case walking
    case other

    var displayName: String {
        switch self {
        case .all: return "All"
        case .running: return "Running"
        case .strength: return "Strength"
        case .swimming: return "Swimming"
        case .cycling: return "Cycling"
        case .walking: return "Walking"
        case .other: return "Other"
        }
    }
}

// Preview
struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutListView()
        }
    }
}
