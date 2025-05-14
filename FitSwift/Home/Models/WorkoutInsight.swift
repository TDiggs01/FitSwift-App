//
//  WorkoutInsight.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/13/25.
//
import Foundation
import SwiftUI

// Data model for workout insights
struct WorkoutInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let recommendation: String?
    let icon: String
    let color: Color
    let type: InsightType

    enum InsightType {
        case achievement
        case observation
        case recommendation
    }
}
