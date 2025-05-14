//
//  WorkoutDetailView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import SwiftUI
import Charts

struct WorkoutDetailView: View {
    let workout: Workout
    @StateObject private var viewModel = WorkoutAIInsightViewModel()
    @State private var isLoadingInsights = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                workoutHeaderSection
                
                Divider()
                
                // Stats section
                workoutStatsSection
                
                Divider()
                
                // AI Insights section
                workoutInsightsSection
                
                Divider()
                
                // Comparison with previous workouts
                if !viewModel.previousWorkouts.isEmpty {
                    workoutComparisonSection
                }
            }
            .padding()
        }
        .navigationTitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadWorkoutDetails(for: workout)
            viewModel.generateInsights(for: workout)
        }
    }
    
    // MARK: - UI Components
    
    private var workoutHeaderSection: some View {
        HStack(spacing: 15) {
            // Workout icon
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(workout.tinColor)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            
            // Workout info
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(workout.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label(workout.duration, systemImage: "clock")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Label(workout.calories, systemImage: "flame.fill")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var workoutStatsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Workout Statistics")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                StatCard(title: "Duration", value: workout.duration, icon: "clock.fill", color: .blue)
                StatCard(title: "Calories", value: workout.calories, icon: "flame.fill", color: .red)
                StatCard(title: "Avg. Heart Rate", value: viewModel.averageHeartRate, icon: "heart.fill", color: .pink)
                StatCard(title: "Max Heart Rate", value: viewModel.maxHeartRate, icon: "waveform.path.ecg", color: .orange)
                StatCard(title: "Distance", value: viewModel.distance, icon: "figure.walk", color: .green)
                StatCard(title: "Pace", value: viewModel.pace, icon: "speedometer", color: .purple)
            }
            
            // Heart rate chart if available
            if !viewModel.heartRateData.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Heart Rate")
                        .font(.headline)
                    
                    Chart {
                        ForEach(viewModel.heartRateData) { dataPoint in
                            LineMark(
                                x: .value("Time", dataPoint.time),
                                y: .value("BPM", dataPoint.value)
                            )
                            .foregroundStyle(Color.red.gradient)
                        }
                    }
                    .frame(height: 200)
                }
                .padding(.top)
            }
        }
    }
    
    private var workoutInsightsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("AI Insights")
                    .font(.headline)
                
                Spacer()
                
                if isLoadingInsights {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding(.bottom, 5)
            
            if !viewModel.insights.isEmpty {
                ForEach(viewModel.insights, id: \.id) { insight in
                    InsightCard(insight: insight)
                }
            } else if !isLoadingInsights {
                Text("No insights available for this workout.")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .onReceive(viewModel.$insights) { insights in
            if !insights.isEmpty {
                isLoadingInsights = false
            }
        }
    }
    
    private var workoutComparisonSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Comparison with Previous Workouts")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Comparison chart
            Chart {
                ForEach(viewModel.previousWorkouts) { workout in
                    BarMark(
                        x: .value("Date", workout.date),
                        y: .value("Duration (min)", workout.durationInMinutes)
                    )
                    .foregroundStyle(workout.id == self.workout.id ? Color.blue : Color.gray)
                }
            }
            .frame(height: 200)
            .padding(.bottom)
            
            // Improvement text
            if let improvement = viewModel.improvementText {
                Text(improvement)
                    .font(.subheadline)
                    .foregroundColor(viewModel.isImproved ? .green : .orange)
                    .padding()
                    .background(viewModel.isImproved ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct InsightCard: View {
    let insight: WorkoutInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: insight.icon)
                    .foregroundColor(insight.color)
                
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(insight.color)
            }
            
            Text(insight.description)
                .font(.body)
            
            if let recommendation = insight.recommendation {
                Text("Recommendation: \(recommendation)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(insight.color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Preview
struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutDetailView(workout: Workout(
                id: 1,
                title: "Running",
                image: "figure.run",
                tinColor: .green,
                duration: "45 mins",
                date: "May 15",
                calories: "320 kcal"
            ))
        }
    }
}
