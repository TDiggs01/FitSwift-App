//
//  FitnessInsight.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/13/25.
//

import Foundation
import SwiftUI

// Data model for general fitness insights
struct FitnessInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let recommendation: String?
    let icon: String
    let color: Color
    let type: InsightType

    enum InsightType: String {
        case achievement = "Achievement"
        case observation = "Observation"
        case recommendation = "Recommendation"
        case trend = "Trend Analysis"
    }
}
