//
//  AddWorkoutView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel

    @State private var title: String = ""
    @State private var duration: String = ""
    @State private var calories: String = ""
    @State private var selectedIcon: String = "figure.run"
    @State private var selectedColor: Color = .green
    @State private var selectedDate = Date()

    // Available workout types with their icons
    private let workoutTypes = [
        ("Running", "figure.run"),
        ("Strength Training", "figure.strengthtraining.traditional"),
        ("Swimming", "figure.pool.swim"),
        ("Cycling", "figure.outdoor.cycle"),
        ("Walking", "figure.walk"),
        ("Hiking", "figure.hiking"),
        ("Yoga", "figure.mind.and.body"),
        ("Basketball", "figure.basketball"),
        ("Soccer", "figure.soccer"),
        ("Tennis", "figure.tennis"),
        ("HIIT", "figure.highintensity.intervaltraining"),
        ("Kickboxing", "figure.kickboxing")
    ]

    // Available colors
    private let colors: [Color] = [
        .green, .blue, .red, .orange, .purple, .pink, .yellow, .teal, .indigo
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Details")) {
                    Picker("Workout Type", selection: $title) {
                        ForEach(workoutTypes, id: \.0) { workoutType in
                            Text(workoutType.0).tag(workoutType.0)
                        }
                    }
                    .onChange(of: title) {
                        if let selectedWorkout = workoutTypes.first(where: { $0.0 == title }) {
                            selectedIcon = selectedWorkout.1
                        }
                    }

                    HStack {
                        Text("Duration")
                        Spacer()
                        TextField("Minutes", text: $duration)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("mins")
                    }

                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Amount", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("kcal")
                    }

                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(color == selectedColor ? Color.primary : Color.clear, lineWidth: 2)
                                        .padding(-4)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }

                Section(header: Text("Preview")) {
                    WorkoutCard(workout: Workout(
                        id: nil,
                        title: title.isEmpty ? "Workout Type" : title,
                        image: selectedIcon,
                        tinColor: selectedColor,
                        duration: duration.isEmpty ? "0 mins" : "\(duration) mins",
                        date: formatDate(selectedDate),
                        calories: calories.isEmpty ? "0 kcal" : "\(calories) kcal"
                    ))
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    Button("Add") {
                        addWorkout()
                    }
                    .foregroundColor(title.isEmpty || duration.isEmpty || calories.isEmpty ? .gray : .blue)
                    .disabled(title.isEmpty || duration.isEmpty || calories.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .onAppear {
                // Set default workout type
                if title.isEmpty && !workoutTypes.isEmpty {
                    title = workoutTypes[0].0
                    selectedIcon = workoutTypes[0].1
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-d"
        return dateFormatter.string(from: date)
    }

    private func addWorkout() {
        let newWorkout = Workout(
            id: viewModel.getNextWorkoutId(),
            title: title,
            image: selectedIcon,
            tinColor: selectedColor,
            duration: "\(duration) mins",
            date: formatDate(selectedDate),
            calories: "\(calories) kcal"
        )

        viewModel.addWorkout(newWorkout)
        dismiss()
    }
}

#Preview {
    AddWorkoutView(viewModel: HomeViewModel())
}
