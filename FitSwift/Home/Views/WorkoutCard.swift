//
//  WorkoutCard.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import SwiftUI


struct WorkoutCard: View {
    @State var workout: Workout
    var body: some View {
        HStack {
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(workout.tinColor)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(10)
            
            VStack(spacing: 16) {
                HStack {
                    Text(workout.title)
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(workout.duration)
                }
                
                HStack {
                    Text(workout.date)
                    Spacer()
                    Text(workout.calories)
                }
                
            }
        }.padding(.horizontal)
        
    }
}


#Preview {
    WorkoutCard(workout: Workout(id: 0, title: "Running", image: "figure.run", tinColor: .cyan, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"))
}
