import Foundation

extension Int {
    func formattedNumberString() -> String {
        return Double(self).formattedNumberString()
    }
}

// Helper extension for random Double with precision
extension Double {
    static func random(in range: ClosedRange<Double>, precision: Int) -> Double {
        let multiplier = pow(10.0, Double(precision))
        let randomValue = Double.random(in: range)
        return (randomValue * multiplier).rounded() / multiplier
    }
}

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
