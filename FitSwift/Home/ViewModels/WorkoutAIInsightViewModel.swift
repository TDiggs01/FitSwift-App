//
//  WorkoutAIInsightViewModel.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import Foundation
import SwiftUI

class WorkoutAIInsightViewModel: ObservableObject {
    @Published var heartRateData: [HeartRateDataPoint] = []
    @Published var previousWorkouts: [PreviousWorkout] = []
    @Published var insights: [WorkoutInsight] = []
    @Published var isImproved: Bool = false
    @Published var improvementText: String?

    // Workout statistics
    @Published var averageHeartRate: String = "N/A"
    @Published var maxHeartRate: String = "N/A"
    @Published var distance: String = "N/A"
    @Published var pace: String = "N/A"

    private let healthManager = HealthManager.shared
    private let geminiService = GeminiService.shared

    func loadWorkoutDetails(for workout: Workout) {
        // In a real app, we would fetch this data from HealthKit
        // For now, we'll generate mock data
        generateMockHeartRateData()
        generateMockWorkoutStats(for: workout)
        fetchPreviousWorkouts(of: workout.title)
    }

    func generateInsights(for workout: Workout) {
        // In a real app, we would use the AI service to generate insights
        // For now, we'll generate mock insights

        // Clear existing insights
        insights.removeAll()

        // Add a slight delay to simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }

            // Generate insights based on workout type
            switch workout.title.lowercased() {
            case "running":
                self.generateRunningInsights(for: workout)
            case "strength training":
                self.generateStrengthTrainingInsights(for: workout)
            case "swimming":
                self.generateSwimmingInsights(for: workout)
            default:
                self.generateGenericInsights(for: workout)
            }

            // Generate comparison insights if we have previous workouts
            if !self.previousWorkouts.isEmpty {
                self.generateComparisonInsights(for: workout)
            }
        }
    }

    // MARK: - Private Methods

    private func generateMockHeartRateData() {
        heartRateData.removeAll()

        // Generate 30 minutes of heart rate data at 1-minute intervals
        let startTime = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()

        for i in 0..<30 {
            let time = Calendar.current.date(byAdding: .minute, value: i, to: startTime) ?? Date()

            // Generate a heart rate between 120-160 with some variation
            let baseHeartRate = 120
            let variation = Int.random(in: 0...40)
            let heartRate = baseHeartRate + variation

            heartRateData.append(HeartRateDataPoint(time: time, value: heartRate))
        }
    }

    private func generateMockWorkoutStats(for workout: Workout) {
        // Calculate average heart rate from our mock data
        if !heartRateData.isEmpty {
            let sum = heartRateData.reduce(0) { $0 + $1.value }
            let avg = sum / heartRateData.count
            averageHeartRate = "\(avg) BPM"

            // Find max heart rate
            if let max = heartRateData.map({ $0.value }).max() {
                maxHeartRate = "\(max) BPM"
            }
        }

        // Generate mock distance and pace based on workout type
        switch workout.title.lowercased() {
        case "running":
            // Extract duration in minutes
            let durationComponents = workout.duration.components(separatedBy: " ")
            if let durationMinutes = Double(durationComponents.first ?? "0") {
                // Assume average pace of 5-7 min/km
                let paceMinutes = Double.random(in: 5...7)
                let distanceKm = durationMinutes / paceMinutes

                distance = String(format: "%.2f km", distanceKm)
                pace = String(format: "%.1f min/km", paceMinutes)
            }
        case "swimming":
            distance = "\(Int.random(in: 500...2000)) m"
            pace = "\(Int.random(in: 2...4)):\(String(format: "%02d", Int.random(in: 0...59))) /100m"
        case "cycling":
            distance = "\(Double.random(in: 5...30, precision: 1)) km"
            pace = "\(Double.random(in: 15...30, precision: 1)) km/h"
        default:
            // For other workout types, we might not have distance/pace
            if Bool.random() {
                distance = "\(Double.random(in: 1...5, precision: 1)) km"
                pace = "N/A"
            }
        }
    }

    private func fetchPreviousWorkouts(of type: String) {
        // In a real app, we would fetch this from HealthKit
        // For now, we'll generate mock data

        // Create 5 previous workouts of the same type
        previousWorkouts.removeAll()

        // Create a mock current workout of the requested type
        let mockCurrentWorkout = Workout(
            id: 0,
            title: type,
            image: getWorkoutImage(for: type),
            tinColor: getWorkoutColor(for: type),
            duration: "30 mins",
            date: Date().formatWorkoutDate(),
            calories: "300 kcal"
        )
        previousWorkouts.append(PreviousWorkout(from: mockCurrentWorkout))

        // Add 4 more mock previous workouts
        for i in 1...4 {
            let daysAgo = i * 3 // Every 3 days
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-d"
            let dateString = dateFormatter.string(from: date)

            // Randomize duration between 20-60 minutes
            let duration = Int.random(in: 20...60)
            let durationString = "\(duration) mins"

            // Randomize calories between 150-500
            let calories = Int.random(in: 150...500)
            let caloriesString = "\(calories) kcal"

            let mockWorkout = Workout(
                id: 100 + i,
                title: type,
                image: "figure.run", // This would be more specific in a real app
                tinColor: .green,
                duration: durationString,
                date: dateString,
                calories: caloriesString
            )

            previousWorkouts.append(PreviousWorkout(from: mockWorkout))
        }

        // Sort by date (assuming date format is consistent)
        previousWorkouts.sort { $0.date > $1.date }

        // Generate improvement text
        generateImprovementText()
    }

    private func generateImprovementText() {
        guard previousWorkouts.count >= 2 else {
            improvementText = nil
            return
        }

        // Assume the first workout is the current one and the second is the previous one
        let current = previousWorkouts[0]
        let previous = previousWorkouts[1]

        let durationDiff = current.durationInMinutes - previous.durationInMinutes
        let caloriesDiff = current.caloriesBurned - previous.caloriesBurned

        // Determine if there was improvement
        isImproved = durationDiff > 0 || caloriesDiff > 0

        if durationDiff > 0 && caloriesDiff > 0 {
            improvementText = "Great progress! You worked out \(Int(durationDiff)) minutes longer and burned \(Int(caloriesDiff)) more calories than your last session."
        } else if durationDiff > 0 {
            improvementText = "You increased your workout duration by \(Int(durationDiff)) minutes compared to your last session."
        } else if caloriesDiff > 0 {
            improvementText = "You burned \(Int(caloriesDiff)) more calories than your last session."
        } else {
            improvementText = "This workout was \(abs(Int(durationDiff))) minutes shorter than your last session. Keep pushing!"
            isImproved = false
        }
    }

    // MARK: - Insight Generation Methods

    private func generateRunningInsights(for workout: Workout) {
        // Achievement insight
        insights.append(WorkoutInsight(
            title: "Great Pace!",
            description: "Your average pace of \(pace) is excellent for your fitness level.",
            recommendation: "Try interval training to improve your speed further.",
            icon: "bolt.fill",
            color: .green,
            type: .achievement
        ))

        // Observation insight
        insights.append(WorkoutInsight(
            title: "Heart Rate Analysis",
            description: "Your heart rate peaked at \(maxHeartRate) during this run, which is within your target zone.",
            recommendation: "For optimal cardiovascular benefits, aim to maintain 70-80% of your max heart rate during runs.",
            icon: "heart.fill",
            color: .red,
            type: .observation
        ))

        // Recommendation insight
        insights.append(WorkoutInsight(
            title: "Recovery Suggestion",
            description: "Based on your running intensity, we recommend a recovery day tomorrow with light stretching or yoga.",
            recommendation: "Hydrate well and consider foam rolling to prevent muscle soreness.",
            icon: "figure.mind.and.body",
            color: .blue,
            type: .recommendation
        ))
    }

    private func generateStrengthTrainingInsights(for workout: Workout) {
        // Achievement insight
        insights.append(WorkoutInsight(
            title: "Consistent Training",
            description: "You've been consistent with strength training, which is key to building muscle and strength.",
            recommendation: "Consider increasing weights by 5-10% for continued progress.",
            icon: "figure.strengthtraining.traditional",
            color: .orange,
            type: .achievement
        ))

        // Observation insight
        insights.append(WorkoutInsight(
            title: "Workout Intensity",
            description: "Your heart rate during this workout indicates a moderate intensity level.",
            recommendation: "To build more strength, try reducing rest periods between sets to 60-90 seconds.",
            icon: "chart.line.uptrend.xyaxis",
            color: .purple,
            type: .observation
        ))

        // Recommendation insight
        insights.append(WorkoutInsight(
            title: "Nutrition Tip",
            description: "For optimal muscle recovery after strength training, consume protein within 30 minutes of your workout.",
            recommendation: "Aim for 20-30g of protein and include some carbohydrates to replenish glycogen stores.",
            icon: "fork.knife",
            color: .blue,
            type: .recommendation
        ))
    }

    private func generateSwimmingInsights(for workout: Workout) {
        // Achievement insight
        insights.append(WorkoutInsight(
            title: "Efficient Swimming",
            description: "You maintained a steady pace throughout your swim, which is great for endurance building.",
            recommendation: "Try incorporating different strokes to engage different muscle groups.",
            icon: "figure.pool.swim",
            color: .blue,
            type: .achievement
        ))

        // Observation insight
        insights.append(WorkoutInsight(
            title: "Calorie Burn",
            description: "Swimming is a full-body workout that efficiently burns calories while being gentle on joints.",
            recommendation: "For variety, try interval swimming with alternating fast and recovery laps.",
            icon: "flame.fill",
            color: .red,
            type: .observation
        ))

        // Recommendation insight
        insights.append(WorkoutInsight(
            title: "Technique Focus",
            description: "Focusing on technique can improve your efficiency and speed in the water.",
            recommendation: "Consider a session with a swim coach to refine your stroke mechanics.",
            icon: "hand.raised.fill",
            color: .green,
            type: .recommendation
        ))
    }

    private func generateGenericInsights(for workout: Workout) {
        // Achievement insight
        insights.append(WorkoutInsight(
            title: "Workout Completed!",
            description: "You've completed a \(workout.duration) \(workout.title) session, burning approximately \(workout.calories).",
            recommendation: "Regular exercise contributes to improved mood, energy levels, and overall health.",
            icon: "checkmark.circle.fill",
            color: .green,
            type: .achievement
        ))

        // Observation insight
        insights.append(WorkoutInsight(
            title: "Activity Analysis",
            description: "Your heart rate during this workout indicates you were working at a moderate intensity level.",
            recommendation: "For cardiovascular health, aim for at least 150 minutes of moderate-intensity activity per week.",
            icon: "heart.text.square.fill",
            color: .red,
            type: .observation
        ))

        // Recommendation insight
        insights.append(WorkoutInsight(
            title: "Recovery Reminder",
            description: "Proper recovery is essential for fitness progress and injury prevention.",
            recommendation: "Make sure to stay hydrated and get adequate sleep tonight to maximize recovery.",
            icon: "bed.double.fill",
            color: .blue,
            type: .recommendation
        ))
    }

    private func generateComparisonInsights(for workout: Workout) {
        guard previousWorkouts.count >= 2 else { return }

        // Get current and previous workout data
        let current = previousWorkouts[0]
        let previous = previousWorkouts[1]

        let durationDiff = current.durationInMinutes - previous.durationInMinutes
        let caloriesDiff = current.caloriesBurned - previous.caloriesBurned

        if durationDiff > 0 || caloriesDiff > 0 {
            // Positive comparison insight
            insights.append(WorkoutInsight(
                title: "Progress Detected!",
                description: isImproved ? improvementText ?? "You're making good progress compared to your previous workout." : "Keep pushing to reach your previous performance levels.",
                recommendation: "Consistent improvement is key to long-term fitness success.",
                icon: "arrow.up.right.circle.fill",
                color: .green,
                type: .achievement
            ))
        } else {
            // Constructive comparison insight
            insights.append(WorkoutInsight(
                title: "Workout Variation",
                description: "This workout was different from your last session. Variation is normal and can be beneficial for overall fitness.",
                recommendation: "Focus on consistency over time rather than comparing individual workouts.",
                icon: "arrow.left.arrow.right.circle.fill",
                color: .orange,
                type: .observation
            ))
        }
    }
}

// MARK: - Helper Methods

private func getWorkoutImage(for type: String) -> String {
    switch type.lowercased() {
    case "running": return "figure.run"
    case "strength training": return "figure.strengthtraining.traditional"
    case "swimming": return "figure.pool.swim"
    case "cycling": return "figure.outdoor.cycle"
    case "walking": return "figure.walk"
    case "basketball": return "figure.basketball"
    case "soccer": return "figure.soccer"
    case "kickboxing": return "figure.kickboxing"
    case "yoga": return "figure.mind.and.body"
    default: return "figure.walk"
    }
}

private func getWorkoutColor(for type: String) -> Color {
    switch type.lowercased() {
    case "running": return .green
    case "strength training": return .orange
    case "swimming": return .blue
    case "cycling": return .purple
    case "walking": return .teal
    case "basketball": return .red
    case "soccer": return .blue
    case "kickboxing": return .purple
    case "yoga": return .indigo
    default: return .gray
    }
}

