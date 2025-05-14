//
//  AIInsightViewModel.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import Foundation
import SwiftUI

class AIInsightViewModel: ObservableObject {
    @Published var insights: [FitnessInsight] = []
    @Published var isLoading = false

    private let healthManager = HealthManager.shared
    private let geminiService = GeminiService.shared

    // Activity metrics
    private var steps: Int = 0
    private var calories: Int = 0
    private var exerciseMinutes: Int = 0
    private var standHours: Int = 0
    private var recentWorkouts: [Workout] = []
    private var weeklyActivityTrends: [String: [Int]] = [:]

    func loadInsights() {
        isLoading = true

        // Clear existing insights
        insights.removeAll()

        // Fetch health data
        fetchHealthData { [weak self] in
            guard let self = self else { return }

            // Generate insights based on the data
            self.generateInsights()

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    // MARK: - Private Methods

    private func fetchHealthData(completion: @escaping () -> Void) {
        let group = DispatchGroup()

        // Fetch steps
        group.enter()
        healthManager.fetchTodaySteps { [weak self] result in
            switch result {
            case .success(let activity):
                let stepsString = activity.amount.replacingOccurrences(of: ",", with: "")
                if let stepsValue = Int(stepsString) {
                    self?.steps = stepsValue
                }
            case .failure:
                self?.steps = 0
            }
            group.leave()
        }

        // Fetch calories
        group.enter()
        healthManager.fetchTodayCaloriesBurned { [weak self] result in
            switch result {
            case .success(let calories):
                self?.calories = Int(calories)
            case .failure:
                self?.calories = 0
            }
            group.leave()
        }

        // Fetch exercise minutes
        group.enter()
        healthManager.fetchTodayExerciseTime { [weak self] result in
            switch result {
            case .success(let exercise):
                self?.exerciseMinutes = Int(exercise)
            case .failure:
                self?.exerciseMinutes = 0
            }
            group.leave()
        }

        // Fetch stand hours
        group.enter()
        healthManager.fetchTodayStandHours { [weak self] result in
            switch result {
            case .success(let hours):
                self?.standHours = hours
            case .failure:
                self?.standHours = 0
            }
            group.leave()
        }

        // Fetch recent workouts
        group.enter()
        healthManager.fetchWorkoutsForMonth(month: Date()) { [weak self] result in
            switch result {
            case .success(let workouts):
                self?.recentWorkouts = workouts
            case .failure:
                self?.recentWorkouts = []
            }
            group.leave()
        }

        // Generate mock weekly trends
        generateMockWeeklyTrends()

        // When all data is fetched, call the completion handler
        group.notify(queue: .main) {
            completion()
        }
    }

    private func generateMockWeeklyTrends() {
        // Generate mock data for weekly trends
        let weekdays = 7

        // Steps trend (increasing)
        var stepsTrend: [Int] = []
        for i in 0..<weekdays {
            let baseSteps = 6000
            let trend = i * 500
            let variation = Int.random(in: -500...500)
            stepsTrend.append(baseSteps + trend + variation)
        }
        weeklyActivityTrends["steps"] = stepsTrend

        // Calories trend (stable with weekend spike)
        var caloriesTrend: [Int] = []
        for i in 0..<weekdays {
            let baseCalories = 400
            let isWeekend = i >= 5 // Saturday and Sunday
            let weekendBonus = isWeekend ? 200 : 0
            let variation = Int.random(in: -50...50)
            caloriesTrend.append(baseCalories + weekendBonus + variation)
        }
        weeklyActivityTrends["calories"] = caloriesTrend

        // Exercise minutes trend (variable)
        var exerciseTrend: [Int] = []
        for _ in 0..<weekdays {
            exerciseTrend.append(Int.random(in: 30...60))
        }
        weeklyActivityTrends["exercise"] = exerciseTrend

        // Stand hours trend (consistent)
        var standTrend: [Int] = []
        for _ in 0..<weekdays {
            standTrend.append(Int.random(in: 10...14))
        }
        weeklyActivityTrends["stand"] = standTrend
    }

    private func generateInsights() {
        // Generate insights based on the fetched data

        // 1. Daily progress insights
        generateDailyProgressInsights()

        // 2. Workout pattern insights
        generateWorkoutPatternInsights()

        // 3. Trend analysis insights
        generateTrendAnalysisInsights()

        // 4. Achievement recognition
        generateAchievementInsights()

        // 5. Personalized recommendations
        generateRecommendationInsights()
    }

    private func generateDailyProgressInsights() {
        // Steps progress
        let stepsGoal = 10000
        let stepsProgress = Float(steps) / Float(stepsGoal)

        if stepsProgress >= 1.0 {
            insights.append(FitnessInsight(
                title: "Daily Step Goal Achieved!",
                description: "Congratulations! You've reached your daily step goal of \(stepsGoal) steps.",
                recommendation: "Keep up the great work! Consider increasing your goal to \(stepsGoal + 1000) steps for an extra challenge.",
                icon: "figure.walk",
                color: .green,
                type: .achievement
            ))
        } else if stepsProgress >= 0.7 {
            insights.append(FitnessInsight(
                title: "Almost There!",
                description: "You're at \(steps) steps, which is \(Int(stepsProgress * 100))% of your daily goal.",
                recommendation: "A short evening walk could help you reach your target of \(stepsGoal) steps.",
                icon: "figure.walk",
                color: .orange,
                type: .observation
            ))
        } else {
            insights.append(FitnessInsight(
                title: "Step Count Update",
                description: "You've taken \(steps) steps today, which is \(Int(stepsProgress * 100))% of your daily goal.",
                recommendation: "Try to incorporate more walking into your day to reach your goal of \(stepsGoal) steps.",
                icon: "figure.walk",
                color: .blue,
                type: .observation
            ))
        }

        // Calories progress
        let caloriesGoal = 600
        let caloriesProgress = Float(calories) / Float(caloriesGoal)

        if caloriesProgress >= 1.0 {
            insights.append(FitnessInsight(
                title: "Calorie Goal Achieved!",
                description: "You've burned \(calories) active calories today, exceeding your goal of \(caloriesGoal) calories.",
                recommendation: nil,
                icon: "flame.fill",
                color: .red,
                type: .achievement
            ))
        }

        // Exercise progress
        let exerciseGoal = 30
        let exerciseProgress = Float(exerciseMinutes) / Float(exerciseGoal)

        if exerciseProgress >= 1.0 {
            insights.append(FitnessInsight(
                title: "Exercise Goal Achieved!",
                description: "You've completed \(exerciseMinutes) minutes of exercise today, meeting the recommended daily activity level.",
                recommendation: "Regular exercise contributes to better cardiovascular health and mood.",
                icon: "heart.fill",
                color: .green,
                type: .achievement
            ))
        }
    }

    private func generateWorkoutPatternInsights() {
        // Analyze recent workouts for patterns
        if recentWorkouts.count >= 3 {
            // Count workout types
            var workoutTypeCounts: [String: Int] = [:]
            for workout in recentWorkouts {
                workoutTypeCounts[workout.title, default: 0] += 1
            }

            // Find most frequent workout
            if let (mostFrequentType, count) = workoutTypeCounts.max(by: { $0.value < $1.value }) {
                insights.append(FitnessInsight(
                    title: "Workout Preference",
                    description: "You seem to enjoy \(mostFrequentType) the most, with \(count) sessions in the past month.",
                    recommendation: "For balanced fitness, consider incorporating different types of workouts into your routine.",
                    icon: "chart.bar.fill",
                    color: .purple,
                    type: .observation
                ))
            }

            // Check for workout frequency
            let workoutsPerWeek = Float(recentWorkouts.count) / 4.0 // Assuming 4 weeks in a month

            if workoutsPerWeek >= 3.0 {
                insights.append(FitnessInsight(
                    title: "Consistent Training",
                    description: "You're averaging about \(String(format: "%.1f", workoutsPerWeek)) workouts per week, which is excellent for fitness progress.",
                    recommendation: "Consistency is key to long-term fitness success. Keep up the great work!",
                    icon: "calendar.badge.clock",
                    color: .green,
                    type: .achievement
                ))
            } else if workoutsPerWeek >= 1.0 {
                insights.append(FitnessInsight(
                    title: "Building Consistency",
                    description: "You're averaging about \(String(format: "%.1f", workoutsPerWeek)) workouts per week.",
                    recommendation: "Try to aim for 3-4 workouts per week for optimal fitness benefits.",
                    icon: "calendar.badge.clock",
                    color: .orange,
                    type: .recommendation
                ))
            }
        } else if recentWorkouts.count > 0 {
            insights.append(FitnessInsight(
                title: "Getting Started",
                description: "You've logged \(recentWorkouts.count) workout(s) recently. Great start!",
                recommendation: "Aim for consistency by scheduling regular workout sessions throughout the week.",
                icon: "figure.walk",
                color: .blue,
                type: .recommendation
            ))
        }
    }

    private func generateTrendAnalysisInsights() {
        // Analyze weekly trends

        // Steps trend
        if let stepsTrend = weeklyActivityTrends["steps"], stepsTrend.count >= 7 {
            let firstHalf = Array(stepsTrend.prefix(3))
            let secondHalf = Array(stepsTrend.suffix(3))

            let firstHalfAvg = firstHalf.reduce(0, +) / firstHalf.count
            let secondHalfAvg = secondHalf.reduce(0, +) / secondHalf.count

            let improvement = secondHalfAvg - firstHalfAvg
            let improvementPercentage = Float(improvement) / Float(firstHalfAvg) * 100

            if improvementPercentage > 10 {
                insights.append(FitnessInsight(
                    title: "Positive Steps Trend",
                    description: "Your daily step count has increased by approximately \(Int(improvementPercentage))% over the past week.",
                    recommendation: "Keep up this positive trend to improve your cardiovascular health and energy levels.",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green,
                    type: .trend
                ))
            } else if improvementPercentage < -10 {
                insights.append(FitnessInsight(
                    title: "Decreasing Steps Trend",
                    description: "Your daily step count has decreased by approximately \(abs(Int(improvementPercentage)))% over the past week.",
                    recommendation: "Try to incorporate more walking into your daily routine, such as taking the stairs or parking farther away.",
                    icon: "chart.line.downtrend.xyaxis",
                    color: .orange,
                    type: .trend
                ))
            }
        }

        // Exercise consistency
        if let exerciseTrend = weeklyActivityTrends["exercise"], exerciseTrend.count >= 7 {
            let daysWithExercise = exerciseTrend.filter { $0 >= 30 }.count

            if daysWithExercise >= 5 {
                insights.append(FitnessInsight(
                    title: "Excellent Exercise Consistency",
                    description: "You've met your exercise goal on \(daysWithExercise) days this week.",
                    recommendation: "Consistent exercise is key to improving fitness and overall health.",
                    icon: "heart.text.square.fill",
                    color: .green,
                    type: .achievement
                ))
            } else if daysWithExercise >= 3 {
                insights.append(FitnessInsight(
                    title: "Good Exercise Frequency",
                    description: "You've met your exercise goal on \(daysWithExercise) days this week.",
                    recommendation: "Try to be active on most days of the week for optimal health benefits.",
                    icon: "heart.text.square.fill",
                    color: .blue,
                    type: .observation
                ))
            }
        }
    }

    private func generateAchievementInsights() {
        // Generate achievement-based insights

        // Check for streak achievements
        let hasExerciseStreak = Bool.random() // In a real app, this would be calculated from actual data

        if hasExerciseStreak {
            let streakDays = Int.random(in: 3...10)
            insights.append(FitnessInsight(
                title: "Exercise Streak: \(streakDays) Days!",
                description: "You've met your exercise goal for \(streakDays) consecutive days.",
                recommendation: "Maintaining consistent exercise habits leads to long-term health benefits.",
                icon: "flame.fill",
                color: .orange,
                type: .achievement
            ))
        }

        // Check for personal records
        let hasNewRecord = Bool.random() // In a real app, this would be calculated from actual data

        if hasNewRecord {
            insights.append(FitnessInsight(
                title: "New Personal Record!",
                description: "You've set a new personal record for daily steps this week.",
                recommendation: "Setting and breaking personal records is a great way to stay motivated.",
                icon: "trophy.fill",
                color: .yellow,
                type: .achievement
            ))
        }
    }

    private func generateRecommendationInsights() {
        // Generate personalized recommendations

        // Activity balance recommendation
        insights.append(FitnessInsight(
            title: "Activity Balance",
            description: "Based on your recent activity patterns, you might benefit from more variety in your workouts.",
            recommendation: "Try incorporating both cardio and strength training for a well-rounded fitness routine.",
            icon: "scale.3d",
            color: .blue,
            type: .recommendation
        ))

        // Recovery recommendation
        let needsRecovery = Bool.random() // In a real app, this would be calculated from actual data

        if needsRecovery {
            insights.append(FitnessInsight(
                title: "Recovery Reminder",
                description: "Your recent activity levels suggest you might benefit from a recovery day.",
                recommendation: "Consider light activities like walking or yoga today to allow your body to recover.",
                icon: "bed.double.fill",
                color: .purple,
                type: .recommendation
            ))
        }

        // Specific workout recommendation based on patterns
        insights.append(FitnessInsight(
            title: "Workout Suggestion",
            description: "Based on your fitness profile and recent activity, here's a personalized workout suggestion.",
            recommendation: "Try a 30-minute HIIT session focusing on full-body movements to efficiently burn calories and build strength.",
            icon: "figure.highintensity.intervaltraining",
            color: .green,
            type: .recommendation
        ))
    }
}
