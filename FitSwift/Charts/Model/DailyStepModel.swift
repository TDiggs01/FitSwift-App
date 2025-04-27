//
//  DailyStepModel.swift
//  FitSwift
//
//  Created by csuftitan on 4/27/25.
//

import Foundation

struct DailyStepModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
