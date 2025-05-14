//
//  WorkoutCard.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import SwiftUI


struct WorkoutCard: View {
    @State var workout: Workout
    var isEditMode: Bool = false
    var onDelete: (() -> Void)? = nil

    var body: some View {
        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
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
                            .foregroundColor(.primary)
                        Spacer()

                        if isEditMode {
                            Button(action: {
                                onDelete?()
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            }
                            .padding(.trailing, 8)
                        }

                        Text(workout.duration)
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text(workout.date)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(workout.calories)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isEditMode ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isEditMode) // Disable navigation when in edit mode
    }
}


#Preview {
    WorkoutCard(workout: Workout(id: 0, title: "Running", image: "figure.run", tinColor: .cyan, duration: "51 mins", date: "Apirl 14", calories: "512 Kcal"))
}
