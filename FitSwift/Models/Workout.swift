import SwiftUI

struct Workout: Identifiable, Hashable {
    let id: Int?
    let title: String
    let image: String
    let tinColor: Color
    let duration: String
    let date: String
    let calories: String
    
    // Add Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(image)
        hasher.combine(duration)
        hasher.combine(date)
        hasher.combine(calories)
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId == rhsId
        }
        return lhs.title == rhs.title &&
               lhs.image == rhs.image &&
               lhs.duration == rhs.duration &&
               lhs.date == rhs.date &&
               lhs.calories == rhs.calories
    }
}
