//
//  ChartDetailViewModel.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import Foundation
import SwiftUI


// Chart display type
enum ChartDisplayType {
    case bar
    case line
}

class ChartDetailViewModel: ObservableObject {
    @Published var chartData: [(date: Date, value: Int)] = []
    @Published var average: String = "0"
    @Published var total: String = "0"
    @Published var highest: String = "0"
    @Published var lowest: String = "0"

    @Published var weeklyTrendDescription: String = ""
    @Published var weeklyTrendIcon: String = "arrow.right"
    @Published var weeklyTrendColor: Color = .gray

    @Published var patternDescription: String = ""
    @Published var goalProgressDescription: String = ""

    @Published var insights: [ChartInsight] = []
    @Published var isLoadingInsights: Bool = false
    @Published var chartDisplayType: ChartDisplayType = .bar

    private let healthManager = HealthManager.shared
    private var chartType: ChartOptions = .oneWeek

    func loadData(for chartType: ChartOptions) {
        self.chartType = chartType

        // Generate chart data based on the chart type
        switch chartType {
        case .oneWeek:
            generateWeeklyData()
        case .oneMonth:
            generateMonthlyData()
        case .threeMonth:
            generateThreeMonthData()
        case .yearToDate:
            generateYTDData()
        case .oneYear:
            generateYearlyData()
        }

        // Calculate statistics
        calculateStatistics()

        // Generate trend descriptions
        generateTrendDescriptions()
    }

    func generateInsights() {
        isLoadingInsights = true
        insights.removeAll()

        // Add a delay to simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }

            // Generate insights based on chart type
            switch self.chartType {
            case .oneWeek:
                self.generateWeeklyInsights()
            case .oneMonth:
                self.generateMonthlyInsights()
            case .threeMonth:
                self.generateQuarterlyInsights()
            case .yearToDate, .oneYear:
                self.generateYearlyInsights()
            }

            self.isLoadingInsights = false
        }
    }

    // MARK: - Private Methods

    private func generateWeeklyData() {
        chartData.removeAll()

        // Generate data for the past 7 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for day in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -day, to: today) ?? today
            let value = Int.random(in: 5000...15000) // Random step count
            chartData.append((date: date, value: value))
        }

        // Sort by date (ascending)
        chartData.sort { $0.date < $1.date }
    }

    private func generateMonthlyData() {
        chartData.removeAll()

        // Generate data for the past 30 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for day in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -day, to: today) ?? today
            let value = Int.random(in: 5000...15000) // Random step count
            chartData.append((date: date, value: value))
        }

        // Sort by date (ascending)
        chartData.sort { $0.date < $1.date }
    }

    private func generateThreeMonthData() {
        chartData.removeAll()

        // Generate data for the past 90 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for day in 0..<90 {
            let date = calendar.date(byAdding: .day, value: -day, to: today) ?? today
            let value = Int.random(in: 5000...15000) // Random step count
            chartData.append((date: date, value: value))
        }

        // Sort by date (ascending)
        chartData.sort { $0.date < $1.date }
    }

    private func generateYTDData() {
        chartData.removeAll()

        // Generate data for each month of the current year
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())

        for month in 1...currentMonth {
            var dateComponents = DateComponents()
            dateComponents.year = currentYear
            dateComponents.month = month
            dateComponents.day = 15 // Middle of the month

            if let date = calendar.date(from: dateComponents) {
                let value = Int.random(in: 150000...300000) // Random monthly step count
                chartData.append((date: date, value: value))
            }
        }
    }

    private func generateYearlyData() {
        chartData.removeAll()

        // Generate data for the past 12 months
        let calendar = Calendar.current
        let today = Date()

        for month in 0..<12 {
            let date = calendar.date(byAdding: .month, value: -month, to: today) ?? today
            let value = Int.random(in: 150000...300000) // Random monthly step count
            chartData.append((date: date, value: value))
        }

        // Sort by date (ascending)
        chartData.sort { $0.date < $1.date }
    }

    private func calculateStatistics() {
        guard !chartData.isEmpty else {
            average = "0"
            total = "0"
            highest = "0"
            lowest = "0"
            return
        }

        // Calculate average
        let sum = chartData.reduce(0) { $0 + $1.value }
        let avg = sum / chartData.count
        average = formatNumber(avg)

        // Calculate total
        total = formatNumber(sum)

        // Find highest and lowest values
        if let maxValue = chartData.map({ $0.value }).max() {
            highest = formatNumber(maxValue)
        }

        if let minValue = chartData.map({ $0.value }).min() {
            lowest = formatNumber(minValue)
        }
    }

    private func generateTrendDescriptions() {
        // Generate weekly trend description
        if chartData.count >= 2 {
            let firstHalf = Array(chartData.prefix(chartData.count / 2))
            let secondHalf = Array(chartData.suffix(chartData.count / 2))

            let firstHalfAvg = firstHalf.reduce(0) { $0 + $1.value } / firstHalf.count
            let secondHalfAvg = secondHalf.reduce(0) { $0 + $1.value } / secondHalf.count

            let percentChange = ((Double(secondHalfAvg) - Double(firstHalfAvg)) / Double(firstHalfAvg)) * 100

            if percentChange > 10 {
                weeklyTrendDescription = "Your activity has increased by \(Int(percentChange))% compared to the earlier period."
                weeklyTrendIcon = "arrow.up.right"
                weeklyTrendColor = .green
            } else if percentChange < -10 {
                weeklyTrendDescription = "Your activity has decreased by \(Int(abs(percentChange)))% compared to the earlier period."
                weeklyTrendIcon = "arrow.down.right"
                weeklyTrendColor = .red
            } else {
                weeklyTrendDescription = "Your activity has remained relatively stable over this period."
                weeklyTrendIcon = "arrow.right"
                weeklyTrendColor = .blue
            }
        } else {
            weeklyTrendDescription = "Not enough data to determine a trend."
        }

        // Generate pattern description
        switch chartType {
        case .oneWeek:
            patternDescription = "You tend to be more active on weekdays, with peaks on Tuesday and Thursday."
        case .oneMonth:
            patternDescription = "Your activity levels are higher during the middle of the week and lower on weekends."
        case .threeMonth:
            patternDescription = "Your activity shows a gradual increase over the past three months, with occasional dips."
        case .yearToDate, .oneYear:
            patternDescription = "Your activity is higher during spring and summer months, with a noticeable decrease during winter."
        }

        // Generate goal progress description
        let goalProgress = Double.random(in: 0.6...1.2) // Random progress between 60% and 120%

        if goalProgress >= 1.0 {
            goalProgressDescription = "You're on track to exceed your goal by \(Int((goalProgress - 1.0) * 100))%."
        } else {
            goalProgressDescription = "You're currently at \(Int(goalProgress * 100))% of your target goal."
        }
    }

    // MARK: - Insight Generation Methods

    private func generateWeeklyInsights() {
        // Trend insight
        insights.append(ChartInsight(
            title: "Weekly Pattern Detected",
            description: "Your activity levels tend to be higher on weekdays and lower on weekends.",
            recommendation: "Try to maintain consistent activity levels throughout the week for optimal health benefits.",
            icon: "chart.xyaxis.line",
            color: .blue,
            type: .pattern
        ))

        // Achievement insight
        if let maxValue = chartData.map({ $0.value }).max(),
           let maxDay = chartData.first(where: { $0.value == maxValue })?.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: maxDay)

            insights.append(ChartInsight(
                title: "Peak Activity Day",
                description: "Your most active day this week was \(dayName) with \(formatNumber(maxValue)) steps.",
                recommendation: "Understanding your natural activity patterns can help you optimize your fitness routine.",
                icon: "star.fill",
                color: .yellow,
                type: .achievement
            ))
        }

        // Recommendation insight
        insights.append(ChartInsight(
            title: "Weekly Goal Progress",
            description: goalProgressDescription,
            recommendation: "Aim for at least 10,000 steps daily for cardiovascular health and weight management.",
            icon: "target",
            color: .green,
            type: .recommendation
        ))
    }

    private func generateMonthlyInsights() {
        // Trend insight
        insights.append(ChartInsight(
            title: "Monthly Activity Trend",
            description: weeklyTrendDescription,
            recommendation: "Consistent activity over time leads to better fitness outcomes than occasional intense bursts.",
            icon: weeklyTrendIcon,
            color: weeklyTrendColor,
            type: .trend
        ))

        // Pattern insight
        insights.append(ChartInsight(
            title: "Activity Patterns",
            description: "Your activity shows a cyclical pattern with peaks every 7 days, suggesting a weekly routine.",
            recommendation: "Consider adding variety to your routine to prevent plateaus and maintain motivation.",
            icon: "waveform.path",
            color: .purple,
            type: .pattern
        ))

        // Recommendation insight
        insights.append(ChartInsight(
            title: "Consistency Opportunity",
            description: "There are 5 days this month where your activity dropped below 5,000 steps.",
            recommendation: "Try to maintain a minimum of 7,500 steps even on rest days to support overall health.",
            icon: "calendar.badge.exclamationmark",
            color: .orange,
            type: .recommendation
        ))
    }

    private func generateQuarterlyInsights() {
        // Trend insight
        insights.append(ChartInsight(
            title: "Quarterly Progress",
            description: "Your average daily activity has \(weeklyTrendColor == .green ? "increased" : "decreased") by approximately \(Int.random(in: 5...20))% over the past three months.",
            recommendation: "Long-term trends are more important than daily fluctuations for health outcomes.",
            icon: "chart.line.uptrend.xyaxis",
            color: weeklyTrendColor,
            type: .trend
        ))

        // Pattern insight
        insights.append(ChartInsight(
            title: "Seasonal Impact",
            description: "Your activity levels show correlation with seasonal changes, with higher activity during warmer months.",
            recommendation: "Plan indoor activities for colder or inclement weather to maintain consistency year-round.",
            icon: "sun.max.fill",
            color: .orange,
            type: .pattern
        ))

        // Achievement insight
        insights.append(ChartInsight(
            title: "Quarterly Achievement",
            description: "You've maintained an average of over \(formatNumber(Int(Double(average.replacingOccurrences(of: ",", with: "")) ?? 0))) steps daily for three consecutive months.",
            recommendation: "This level of consistency contributes significantly to long-term health benefits.",
            icon: "medal.fill",
            color: .yellow,
            type: .achievement
        ))
    }

    private func generateYearlyInsights() {
        // Trend insight
        insights.append(ChartInsight(
            title: "Annual Activity Pattern",
            description: "Your activity shows seasonal variation with peaks in \(Bool.random() ? "spring and summer" : "summer and fall") months.",
            recommendation: "Planning for seasonal variations can help maintain consistent activity levels year-round.",
            icon: "calendar",
            color: .blue,
            type: .trend
        ))

        // Achievement insight
        insights.append(ChartInsight(
            title: "Year in Review",
            description: "You've taken approximately \(formatNumber(Int(Double(total.replacingOccurrences(of: ",", with: "")) ?? 0))) steps this year, equivalent to about \(Int.random(in: 1500...3000)) miles.",
            recommendation: nil,
            icon: "figure.walk",
            color: .green,
            type: .achievement
        ))

        // Recommendation insight
        insights.append(ChartInsight(
            title: "Long-term Strategy",
            description: "Based on your annual activity patterns, we've identified opportunities to improve your fitness routine.",
            recommendation: "Consider setting monthly goals that adapt to seasonal changes and your personal schedule.",
            icon: "brain.head.profile",
            color: .purple,
            type: .recommendation
        ))
    }

    // MARK: - Helper Methods

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
}
