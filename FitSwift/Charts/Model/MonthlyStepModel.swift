//
//  MonthlyStepModel.swift
//  FitSwift
//
//  Created by csuftitan on 4/27/25.
//

import Foundation

struct MonthlyStepModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
