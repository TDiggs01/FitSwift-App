//
//  InsightsView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = AIInsightViewModel()
    @State private var selectedFilter: InsightFilter = .all
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("AI Fitness Insights")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Text("Personalized observations and recommendations based on your fitness data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(InsightFilter.allCases, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter.displayName)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Insights
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        VStack(spacing: 15) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Analyzing your fitness data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 50)
                } else if viewModel.insights.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No insights available")
                                .font(.headline)
                            Text("We need more fitness data to generate personalized insights")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredInsights) { insight in
                            InsightCardView(insight: insight)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("AI Insights")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadInsights()
        }
    }
    
    // Filter insights based on selected filter
    private var filteredInsights: [FitnessInsight] {
        switch selectedFilter {
        case .all:
            return viewModel.insights
        case .achievements:
            return viewModel.insights.filter { $0.type == .achievement }
        case .observations:
            return viewModel.insights.filter { $0.type == .observation }
        case .recommendations:
            return viewModel.insights.filter { $0.type == .recommendation }
        case .trends:
            return viewModel.insights.filter { $0.type == .trend }
        }
    }
}

// Insight filter options
enum InsightFilter: String, CaseIterable {
    case all
    case achievements
    case observations
    case recommendations
    case trends
    
    var displayName: String {
        switch self {
        case .all: return "All Insights"
        case .achievements: return "Achievements"
        case .observations: return "Observations"
        case .recommendations: return "Recommendations"
        case .trends: return "Trends"
        }
    }
}

// Insight card view
struct InsightCardView: View {
    let insight: FitnessInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Image(systemName: insight.icon)
                    .font(.title3)
                    .foregroundColor(insight.color)
                
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(insight.color)
                
                Spacer()
                
                Text(insight.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(insight.color.opacity(0.2))
                    .foregroundColor(insight.color)
                    .cornerRadius(8)
            }
            
            // Description
            Text(insight.description)
                .font(.body)
            
            // Recommendation (if any)
            if let recommendation = insight.recommendation {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.8))
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Preview
struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InsightsView()
        }
    }
}
