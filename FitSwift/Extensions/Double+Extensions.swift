import Foundation

// Comment out the duplicate extension
/*
extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
*/

extension Int {
    func formattedNumberString() -> String {
        return Double(self).formattedNumberString()
    }
}
