//
//  HomeViewModel.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {

    let healthManager = HealthManager.shared

    @Published var userName: String = "Fitness User"
    @Published var calories: Int = 0
    @Published var exercise: Int = 0
    @Published var stand: Int = 0

    @Published var activities = [Activity]()
    @Published var workouts = [
        Workout(id: 0, title: "Running", image: "figure.run", tinColor: .green, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
        Workout(id: 1, title: "Strength Training", image: "figure.strengthtraining.traditional", tinColor: .red, duration: "5 mins", date: "Apirl 4", calories: "512 Kcal"),
        Workout(id: 2, title: "Swimming", image: "figure.pool.swim", tinColor: .blue, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
        Workout(id: 3, title: "Running", image: "figure.run", tinColor: .purple, duration: "1 mins", date: "Apirl 1", calories: "512 Kcal")
    ]

    // UI state for add/edit sheets
    @Published var showingAddActivitySheet = false
    @Published var showingAddWorkoutSheet = false
    @Published var isEditMode = false

    // Sample activities for testing
    @Published var mockActivities = [
        Activity(title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .green, amount: "6,000"),
        Activity(title: "Today Steps", subTitle: "Goal: 1,000 steps", image: "figure.walk", tinColor: .red, amount: "678"),
        Activity(title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .blue, amount: "9,812"),
        Activity(title: "Today Steps", subTitle: "Goal: 50,000 steps", image: "figure.run", tinColor: .purple, amount: "19,000")
    ]

    // Sample workouts for testing
    var mockWorkouts = [
        Workout(id: 0, title: "Running", image: "figure.run", tinColor: .green, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
        Workout(id: 2, title: "Strength Training", image: "figure.strengthtraining.traditional", tinColor: .red, duration: "5 mins", date: "Apirl 4", calories: "512 Kcal"),
        Workout(id: 3, title: "Swimming", image: "figure.pool.swim", tinColor: .blue, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
        Workout(id: 4, title: "Running", image: "figure.run", tinColor: .purple, duration: "1 mins", date: "Apirl 1", calories: "512 Kcal")
    ]

    // MARK: - Activity and Workout Management

    func addActivity(_ activity: Activity) {
        DispatchQueue.main.async {
            self.activities.append(activity)
        }
    }

    func removeActivity(at indexSet: IndexSet) {
        DispatchQueue.main.async {
            self.activities.remove(atOffsets: indexSet)
        }
    }

    func removeActivity(_ activity: Activity) {
        DispatchQueue.main.async {
            if let index = self.activities.firstIndex(where: {
                $0.title == activity.title &&
                $0.amount == activity.amount &&
                $0.image == activity.image
            }) {
                self.activities.remove(at: index)
            }
        }
    }

    func addWorkout(_ workout: Workout) {
        DispatchQueue.main.async {
            self.workouts.insert(workout, at: 0) // Add to the beginning for most recent
        }
    }

    func removeWorkout(at indexSet: IndexSet) {
        DispatchQueue.main.async {
            self.workouts.remove(atOffsets: indexSet)
        }
    }

    func removeWorkout(_ workout: Workout) {
        DispatchQueue.main.async {
            if let index = self.workouts.firstIndex(of: workout) {
                self.workouts.remove(at: index)
            }
        }
    }

    func getNextWorkoutId() -> Int {
        // Find the highest ID and increment by 1
        let highestId = workouts.compactMap { $0.id }.max() ?? 0
        return highestId + 1
    }

    func toggleEditMode() {
        isEditMode.toggle()
    }

    init() {
        // Use mock data for testing if HealthKit is not available
        #if targetEnvironment(simulator)
        // Add some initial activities for testing
        if activities.isEmpty {
            activities = [
                Activity(title: "Steps", subTitle: "Goal: 10,000 steps", image: "figure.walk", tinColor: .green, amount: "7,523"),
                Activity(title: "Calories", subTitle: "Today", image: "flame.fill", tinColor: .red, amount: "423")
            ]
        }
        #else
        Task {
            do {
                try await healthManager.requestHealthKitAccess()
                fetchTodayCalories()
                fetchTodayExerciseTime()
                fetchTodayStandHours()
                fetchTodaysSteps()
                fetchCurrentWeekActivities()
                fetchRecentWorkouts()
            } catch {
                print(error.localizedDescription)

                // Fall back to mock data if HealthKit fails
                if activities.isEmpty {
                    activities = [
                        Activity(title: "Steps", subTitle: "Goal: 10,000 steps", image: "figure.walk", tinColor: .green, amount: "7,523"),
                        Activity(title: "Calories", subTitle: "Today", image: "flame.fill", tinColor: .red, amount: "423")
                    ]
                }
            }
        }
        #endif
    }

    func fetchTodayCalories() {
        healthManager.fetchTodayCaloriesBurned { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    self.calories = Int(calories)
                    let activity = Activity(title: "Calories Burned", subTitle: "Today", image: "flame", tinColor: .red, amount: calories.formattedNumberString())
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    func fetchTodayExerciseTime() {
        healthManager.fetchTodayExerciseTime { result in
            switch result {
            case .success(let exercise):
                DispatchQueue.main.async {
                    self.exercise = Int(exercise)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    func fetchTodayStandHours() {
        healthManager.fetchTodayStandHours { result in
            switch result {
            case .success(let hours):
                DispatchQueue.main.async {
                    self.stand = hours
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    // Fitness activities
    func fetchTodaysSteps() {
        healthManager.fetchTodaySteps { result in
            switch result {
            case .success(let activity):
                DispatchQueue.main.async {
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    func fetchCurrentWeekActivities() {
        healthManager.fetchCurrentWeekWorkoutStats { result in
            switch result {
            case .success(let activities):
                DispatchQueue.main.async {
                    self.activities.append(contentsOf: activities)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

    // MARK: Recent Workouts
    func fetchRecentWorkouts() {
        healthManager.fetchWorkoutsForMonth(month: Date()) { result in
            switch result {
            case .success(let workouts):
                DispatchQueue.main.async {
                    self.workouts.append(contentsOf: workouts)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}

