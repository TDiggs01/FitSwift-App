//
//  ChartDataPoint.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/13/25.
//
import Foundation

// Chart data point structure
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
