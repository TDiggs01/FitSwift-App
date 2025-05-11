//
//  HealthManager.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2
        
        return calendar.date(from: components) ?? Date()
    }
    
    func fetchMonthStartAndEndDate() -> (Date, Date) {
        let calendar = Calendar.current
        let startDateComponent = calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self))
        let startDate = calendar.date(from: startDateComponent) ?? self
        let endDate = calendar.date(byAdding: DateComponents(month:  1, day: -1), to: startDate) ?? self
        
        return (startDate, endDate)
    }
    
    func formatWorkoutDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-d"
        return formatter.string(from: self)
    }
}

extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
    
}

class HealthManager {
    
    static let shared = HealthManager()
    let healthStore = HKHealthStore()
    
    // Flag to check if we're running on a simulator
    private let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
    // Mock data for simulator testing
    private struct MockData {
        static let steps = 8742
        static let calories = 423.5
        static let exerciseMinutes = 42.0
        static let standHours = 9
        
        static let workouts: [Workout] = [
            Workout(id: 1, title: "Running", image: "figure.run", tinColor: .green, duration: "32 mins", date: Date().formatWorkoutDate(), calories: "320 kcal"),
            Workout(id: 2, title: "Strength Training", image: "figure.strengthtraining.traditional", tinColor: .orange, duration: "45 mins", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())?.formatWorkoutDate() ?? "", calories: "280 kcal"),
            Workout(id: 3, title: "Basketball", image: "figure.basketball", tinColor: .red, duration: "60 mins", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())?.formatWorkoutDate() ?? "", calories: "450 kcal"),
            Workout(id: 4, title: "Soccer", image: "figure.soccer", tinColor: .blue, duration: "75 mins", date: Calendar.current.date(byAdding: .day, value: -5, to: Date())?.formatWorkoutDate() ?? "", calories: "520 kcal"),
            Workout(id: 5, title: "Kickboxing", image: "figure.kickboxing", tinColor: .purple, duration: "30 mins", date: Calendar.current.date(byAdding: .day, value: -7, to: Date())?.formatWorkoutDate() ?? "", calories: "310 kcal")
        ]
        
        static let weeklyWorkoutMinutes = [
            ("Running", 85),
            ("Strength Training", 120),
            ("Soccer", 75),
            ("Basketball", 60),
            ("Stairstepper", 25),
            ("Kickboxing", 30)
        ]
    }
    
    private init() {
        if !isSimulator {
            Task {
                do {
                    try await requestHealthKitAccess()
                } catch {
                    print("HealthKit access error: \(error.localizedDescription)")
                }
            }
        } else {
            print("Running on simulator - HealthKit will use mock data")
        }
    }
    
    func requestHealthKitAccess() async throws {
        // Skip on simulator
        if isSimulator { return }
        
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKCategoryType(.appleStandHour)
        let steps = HKQuantityType(.stepCount)
        let workouts = HKSampleType.workoutType()
        
        let healthTypes: Set = [ calories, exercise, stand, steps, workouts]
        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    func fetchTodayCaloriesBurned(completion: @escaping(Result<Double, Error>) -> Void) {
        if isSimulator {
            completion(.success(MockData.calories))
            return
        }
        
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to fetch calories burned data."
                ])))
                return
            }
            
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(calorieCount))
        }
        healthStore.execute(query)
    }
    
    func fetchTodayExerciseTime(completion: @escaping(Result<Double, Error>) -> Void) {
        if isSimulator {
            completion(.success(MockData.exerciseMinutes))
            return
        }
        
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to fetch exercise time data."
                ])))
                return
            }
            
            let exerciseTime = quantity.doubleValue(for: .minute())
            completion(.success(exerciseTime))
        }
        healthStore.execute(query)
    }
    
    func fetchTodayStandHours(completion: @escaping(Result<Int, Error>) -> Void) {
        if isSimulator {
            completion(.success(MockData.standHours))
            return
        }
        
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to fetch stand hours data."
                ])))
                return
            }
            
            let standCount = samples.filter({$0.value == 0}).count
            completion(.success(standCount))
        }
        healthStore.execute(query)
    }
    
    // User: Fitness Activity
    func fetchTodaySteps(completion: @escaping(Result<Activity, Error>) -> Void) {
        // Return mock data on simulator
        if isSimulator {
            let stepsString = String(format: "%d", MockData.steps)
            let mockActivity = Activity(
                title: "Today Steps", 
                subTitle: "Goal: 10,000 steps", 
                image: "figure.walk", 
                tinColor: .green, 
                amount: stepsString
            )
            completion(.success(mockActivity))
            return
        }
        
        // Real implementation for device
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to fetch steps data."
                ])))
                return
            }
            
            let steps = quantity.doubleValue(for: .count())
            let stepsString = String(format: "%.0f", steps)
            let activity = Activity(title: "Today Steps", subTitle: "Goal: 10,000 steps", image: "figure.walk", tinColor: .green, amount: stepsString)
            completion(.success(activity))
        }
        healthStore.execute(query)
    }
    
    // Workouts for the week
    func fetchCurrentWeekWorkoutStats(completion: @escaping(Result<[Activity], Error>) -> Void) {
        if isSimulator {
            let activities = MockData.weeklyWorkoutMinutes.map { (workout, minutes) in
                Activity(
                    title: workout,
                    subTitle: "This week",
                    image: workoutTypeToImageName(workout),
                    tinColor: .green,
                    amount: "\(minutes) mins"
                )
            }
            completion(.success(activities))
            return
        }
        
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
            guard let workouts = results as? [HKWorkout], let self = self, error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            var runningCount: Int = 0
            var strengthCount: Int = 0
            var soccerCount: Int = 0
            var basketballCount: Int = 0
            var stairsCount: Int = 0
            var kickboxingCount: Int = 0
            
            for workout in workouts {
                let duration = Int(workout.duration)/60
                if workout.workoutActivityType == .running {
                    runningCount += duration
                } else if workout.workoutActivityType == .traditionalStrengthTraining {
                    strengthCount += duration
                } else if workout.workoutActivityType == .soccer {
                    soccerCount += duration
                } else if workout.workoutActivityType == .basketball {
                    basketballCount += duration
                } else if workout.workoutActivityType == .stairClimbing {
                    stairsCount += duration
                } else if workout.workoutActivityType == .kickboxing {
                    kickboxingCount += duration
                }
            }
            
            completion(.success(self.generateActivitiesFromDurations(running: runningCount, strength: strengthCount, soccer: soccerCount, basketball: basketballCount, stairs: stairsCount, kickboxing: kickboxingCount)))
        }
        healthStore.execute(query)
    }
    
    func generateActivitiesFromDurations(running: Int, strength: Int, soccer: Int, basketball: Int, stairs: Int, kickboxing: Int) -> [Activity] {
        return [
            Activity(title: "Running", subTitle: "This week", image: "figure.run", tinColor: .green, amount: "\(running) mins"),
            Activity(title: "Strength Training", subTitle: "This week", image: "figure.strengthtraining.traditional", tinColor: .green, amount: "\(strength)"),
            Activity(title: "Soccer", subTitle: "This week", image: "figure.soccer", tinColor: .green, amount: "\(soccer)"),
            Activity(title: "Basketball", subTitle: "This week", image: "figure.basketball", tinColor: .green, amount: "\(basketball)"),
            Activity(title: "Stairstepper", subTitle: "This week", image: "figure.stairs", tinColor: .green, amount: "\(stairs)"),
            Activity(title: "Kickboxing", subTitle: "This week", image: "figure.kickboxing", tinColor: .green, amount: "\(kickboxing) mins")
        ]
    }
    
    // MARK: Recent workouts
    func fetchWorkoutsForMonth(month: Date, completion: @escaping(Result<[Workout], Error>) -> Void) {
        if isSimulator {
            completion(.success(MockData.workouts))
            return
        }
        
        let workouts = HKSampleType.workoutType()
        let (startDate, endDate) = month.fetchMonthStartAndEndDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (_, results, error) in
            guard let workouts = results as? [HKWorkout], error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            let workoutsArray = workouts.map({ Workout(id: nil, title: $0.workoutActivityType.name, image: $0.workoutActivityType.image, tinColor: $0.workoutActivityType.color, duration: "\(Int($0.duration)/60) mins", date: $0.startDate.formatWorkoutDate(), calories: ($0.totalEnergyBurned?.doubleValue(for: .kilocalorie()).formattedNumberString() ?? "-") + " kcal") })
            completion(.success(workoutsArray))
        }
        healthStore.execute(query)
    }
    
    // MARK: - Chart Data
    func fetchYTDAndOneYearChartData(completion: @escaping (Result<YearChartDataResult, Error>) -> Void) {
        if isSimulator {
            // Generate mock monthly data for the past year
            var oneYearMonths = [MonthlyStepModel]()
            var ytdMonths = [MonthlyStepModel]()
            
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            
            for i in 0...11 {
                let month = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
                let randomSteps = Int.random(in: 150000...300000) // Random monthly steps between 150k-300k
                
                let monthModel = MonthlyStepModel(date: month, count: randomSteps)
                oneYearMonths.append(monthModel)
                
                // Only add to YTD if it's in the current year
                if calendar.component(.year, from: month) == currentYear {
                    ytdMonths.append(monthModel)
                }
            }
            
            completion(.success(YearChartDataResult(ytd: ytdMonths, oneYear: oneYearMonths)))
            return
        }
        
        let steps = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        
        var onYearMonths = [MonthlyStepModel]()
        var ytdMonths = [MonthlyStepModel]()
        for i in 0...11 {
            let month = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
            
            let (startOfMonth, endOfMonth) = month.fetchMonthStartAndEndDate()
            let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth)
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
                guard let steps = results?.sumQuantity()?.doubleValue(for: .count()), error == nil else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                
                if i == 0 {
                    onYearMonths.append(MonthlyStepModel(date: month, count: Int(steps)))
                    ytdMonths.append(MonthlyStepModel(date: month, count: Int(steps)))
                } else {
                    // Current month is within the current year
                    onYearMonths.append(MonthlyStepModel(date: month, count: Int(steps)))
                    if calendar.component(.year, from: Date()) == calendar.component(.year, from: month) {
                        ytdMonths.append(MonthlyStepModel(date: month, count: Int(steps)))
                    }
                }
                if i == 11 {
                    // Array is done and data is complete
                    completion(.success(YearChartDataResult(ytd: ytdMonths, oneYear: onYearMonths)))
                }
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: - Helper Methods
    private func workoutTypeToImageName(_ workoutType: String) -> String {
        switch workoutType.lowercased() {
        case "running": return "figure.run"
        case "strength training": return "figure.strengthtraining.traditional"
        case "soccer": return "figure.soccer"
        case "basketball": return "figure.basketball"
        case "stairstepper": return "figure.stairs"
        case "kickboxing": return "figure.kickboxing"
        default: return "figure.walk"
        }
    }
}

// MARK: ChartsView Data
extension HealthManager {
    
    struct YearChartDataResult {
        let ytd: [MonthlyStepModel]
        let oneYear: [MonthlyStepModel]
    }
    
    // This method is already defined above, so we're removing the duplicate
    // func fetchYTDAndOneYearChartData(completion: @escaping (Result<YearChartDataResult, Error>) -> Void) { ... }
}
