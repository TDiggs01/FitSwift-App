//
//  HomeViewModel.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    var calories: Int = 123
    var active: Int = 52
    var stand: Int = 8
    
    @Published var mockActivities = [Activity(id: 0, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .green, amount: "6,000"),
            Activity(id: 1, title: "Today Steps", subTitle: "Goal: 1,000 steps", image: "figure.walk", tinColor: .red, amount: "678"),
            Activity(id: 2, title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .blue, amount: "9,812"),
            Activity(id: 3, title: "Today Steps", subTitle: "Goal: 50,000 steps", image: "figure.run", tinColor: .purple, amount: "19,000")
        ]
    
    var mockWorkouts = [
            Workout(id: 0, title: "Running", image: "figure.run", tinColor: .green, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
            Workout(id: 2, title: "Strength  Training", image: "figure.run", tinColor: .red, duration: "5 mins", date: "Apirl 4", calories: "512 Kcal"),
            Workout(id: 3, title: "Swimming", image: "figure.run", tinColor: .blue, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"),
            Workout(id: 4, title: "Running", image: "figure.run", tinColor: .purple, duration: "1 mins", date: "Apirl 1", calories: "512 Kcal")
        ]
}
