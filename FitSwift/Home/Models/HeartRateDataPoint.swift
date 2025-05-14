//
//  HeartRateDataPoint.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/13/25.
//
import Foundation

// Data model for heart rate data points
struct HeartRateDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let value: Int
}
