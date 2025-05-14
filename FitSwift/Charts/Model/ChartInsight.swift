//
//  ChartInsight.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/13/25.
//

import Foundation
import SwiftUI

// Data model for chart insights
struct ChartInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let recommendation: String?
    let icon: String
    let color: Color
    let type: InsightType

    enum InsightType: String {
        case trend = "Trend"
        case pattern = "Pattern"
        case achievement = "Achievement"
        case recommendation = "Recommendation"
    }
}
