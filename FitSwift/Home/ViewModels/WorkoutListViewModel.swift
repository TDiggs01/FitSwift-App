//
//  WorkoutListViewModel.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import Foundation
import SwiftUI

class WorkoutListViewModel: ObservableObject {
    @Published var allWorkouts: [Workout] = []
    @Published var filteredWorkouts: [Workout] = []
    @Published var isLoading = false
    
    private let healthManager = HealthManager.shared
    
    func loadWorkouts() {
        isLoading = true
        
        // Fetch workouts from the past 6 months
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        
        // In a real app, we would fetch workouts for each month in the range
        // For simplicity, we'll just fetch the current month's workouts and add some mock data
        healthManager.fetchWorkoutsForMonth(month: Date()) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let workouts):
                DispatchQueue.main.async {
                    // Add the fetched workouts
                    self.allWorkouts = workouts
                    
                    // Add mock workouts for previous months
                    self.addMockWorkoutsForPreviousMonths(startingFrom: sixMonthsAgo)
                    
                    // Sort workouts by date (most recent first)
                    self.allWorkouts.sort { workout1, workout2 in
                        // Convert date strings to Date objects for comparison
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM-d"
                        
                        guard let date1 = dateFormatter.date(from: workout1.date),
                              let date2 = dateFormatter.date(from: workout2.date) else {
                            return false
                        }
                        
                        return date1 > date2
                    }
                    
                    // Initialize filtered workouts with all workouts
                    self.filteredWorkouts = self.allWorkouts
                    self.isLoading = false
                }
            case .failure:
                // If real data fails, use mock data
                DispatchQueue.main.async {
                    self.generateMockWorkouts()
                    self.filteredWorkouts = self.allWorkouts
                    self.isLoading = false
                }
            }
        }
    }
    
    func filterWorkouts(by filter: WorkoutFilter, searchText: String = "") {
        // Apply filter
        var filtered = allWorkouts
        
        // Filter by workout type
        if filter != .all {
            filtered = filtered.filter { workout in
                switch filter {
                case .all:
                    return true
                case .running:
                    return workout.title.lowercased().contains("run")
                case .strength:
                    return workout.title.lowercased().contains("strength") || workout.title.lowercased().contains("weight")
                case .swimming:
                    return workout.title.lowercased().contains("swim")
                case .cycling:
                    return workout.title.lowercased().contains("cycl") || workout.title.lowercased().contains("bike")
                case .walking:
                    return workout.title.lowercased().contains("walk")
                case .other:
                    let commonTypes = ["run", "strength", "weight", "swim", "cycl", "bike", "walk"]
                    return !commonTypes.contains { workout.title.lowercased().contains($0) }
                }
            }
        }
        
        // Apply search text if provided
        if !searchText.isEmpty {
            filtered = filtered.filter { workout in
                workout.title.lowercased().contains(searchText.lowercased()) ||
                workout.date.lowercased().contains(searchText.lowercased()) ||
                workout.duration.lowercased().contains(searchText.lowercased()) ||
                workout.calories.lowercased().contains(searchText.lowercased())
            }
        }
        
        filteredWorkouts = filtered
    }
    
    // MARK: - Private Methods
    
    private func generateMockWorkouts() {
        allWorkouts = []
        
        // Generate mock workouts for the past 6 months
        let calendar = Calendar.current
        let today = Date()
        
        // Workout types
        let workoutTypes = [
            ("Running", "figure.run", Color.green),
            ("Strength Training", "figure.strengthtraining.traditional", Color.orange),
            ("Swimming", "figure.pool.swim", Color.blue),
            ("Cycling", "figure.outdoor.cycle", Color.purple),
            ("Walking", "figure.walk", Color.teal),
            ("Basketball", "figure.basketball", Color.red),
            ("Yoga", "figure.mind.and.body", Color.indigo)
        ]
        
        // Generate 30 random workouts
        for i in 0..<30 {
            // Random date within the past 6 months
            let daysAgo = Int.random(in: 0...180)
            let workoutDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            
            // Format date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-d"
            let dateString = dateFormatter.string(from: workoutDate)
            
            // Random workout type
            let workoutType = workoutTypes.randomElement()!
            
            // Random duration between 15-120 minutes
            let duration = Int.random(in: 15...120)
            let durationString = "\(duration) mins"
            
            // Random calories between 100-800
            let calories = Int.random(in: 100...800)
            let caloriesString = "\(calories) kcal"
            
            // Create workout
            let workout = Workout(
                id: i,
                title: workoutType.0,
                image: workoutType.1,
                tinColor: workoutType.2,
                duration: durationString,
                date: dateString,
                calories: caloriesString
            )
            
            allWorkouts.append(workout)
        }
        
        // Sort by date (most recent first)
        allWorkouts.sort { workout1, workout2 in
            // Convert date strings to Date objects for comparison
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-d"
            
            guard let date1 = dateFormatter.date(from: workout1.date),
                  let date2 = dateFormatter.date(from: workout2.date) else {
                return false
            }
            
            return date1 > date2
        }
    }
    
    private func addMockWorkoutsForPreviousMonths(startingFrom date: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        // Workout types
        let workoutTypes = [
            ("Running", "figure.run", Color.green),
            ("Strength Training", "figure.strengthtraining.traditional", Color.orange),
            ("Swimming", "figure.pool.swim", Color.blue),
            ("Cycling", "figure.outdoor.cycle", Color.purple),
            ("Walking", "figure.walk", Color.teal),
            ("Basketball", "figure.basketball", Color.red),
            ("Yoga", "figure.mind.and.body", Color.indigo)
        ]
        
        // Generate 5 workouts per month for the past 6 months
        for month in 1...5 {
            let monthsAgo = month
            let monthDate = calendar.date(byAdding: .month, value: -monthsAgo, to: today) ?? today
            
            for day in 0..<5 {
                // Random day within the month
                let daysOffset = Int.random(in: 1...28)
                var dateComponents = calendar.dateComponents([.year, .month], from: monthDate)
                dateComponents.day = daysOffset
                
                guard let workoutDate = calendar.date(from: dateComponents) else { continue }
                
                // Format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM-d"
                let dateString = dateFormatter.string(from: workoutDate)
                
                // Random workout type
                let workoutType = workoutTypes.randomElement()!
                
                // Random duration between 15-120 minutes
                let duration = Int.random(in: 15...120)
                let durationString = "\(duration) mins"
                
                // Random calories between 100-800
                let calories = Int.random(in: 100...800)
                let caloriesString = "\(calories) kcal"
                
                // Create workout
                let workout = Workout(
                    id: allWorkouts.count + (month * 10) + day,
                    title: workoutType.0,
                    image: workoutType.1,
                    tinColor: workoutType.2,
                    duration: durationString,
                    date: dateString,
                    calories: caloriesString
                )
                
                allWorkouts.append(workout)
            }
        }
    }
}
