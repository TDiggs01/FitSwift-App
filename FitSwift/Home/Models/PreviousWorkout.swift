//
//  PreviousWorkout.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/13/25.
//
import Foundation

// Data model for previous workout comparison
struct PreviousWorkout: Identifiable {
    let id: Int?
    let date: String
    let durationInMinutes: Double
    let caloriesBurned: Double

    init(from workout: Workout) {
        self.id = workout.id
        self.date = workout.date

        // Extract duration in minutes from string like "45 mins"
        let durationComponents = workout.duration.components(separatedBy: " ")
        self.durationInMinutes = Double(durationComponents.first ?? "0") ?? 0

        // Extract calories from string like "320 kcal"
        let caloriesComponents = workout.calories.components(separatedBy: " ")
        self.caloriesBurned = Double(caloriesComponents.first ?? "0") ?? 0
    }
}
