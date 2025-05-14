//
//  ChartDetailView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import SwiftUI
import Charts

struct ChartDetailView: View {
    let chartType: ChartOptions
    let title: String

    @StateObject private var viewModel = ChartDetailViewModel()
    @State private var selectedDataPoint: (date: Date, value: Int)? = nil
    @State private var isShowingInsights = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Chart header with stats
                chartHeaderSection

                Divider()

                // Main chart
                chartSection

                Divider()

                // Trend analysis
                trendAnalysisSection

                Divider()

                // AI Insights button
                Button {
                    isShowingInsights.toggle()
                } label: {
                    HStack {
                        Image(systemName: "brain")
                        Text(isShowingInsights ? "Hide AI Insights" : "Show AI Insights")
                        Spacer()
                        Image(systemName: isShowingInsights ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // AI Insights section (conditionally shown)
                if isShowingInsights {
                    insightsSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut, value: isShowingInsights)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadData(for: chartType)
            // Pre-load insights so they're ready when the user taps the button
            viewModel.generateInsights()
        }
    }

    // MARK: - UI Components

    private var chartHeaderSection: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Average")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.average)")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.total)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Highest")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.highest)")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Lowest")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.lowest)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detailed View")
                .font(.headline)
                .padding(.horizontal)

            // Interactive chart
            Chart {
                ForEach(viewModel.chartData, id: \.date) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Value", dataPoint.value)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .annotation(position: .top) {
                        if selectedDataPoint?.date == dataPoint.date {
                            Text("\(dataPoint.value)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let selected = selectedDataPoint {
                    RuleMark(x: .value("Selected", selected.date))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top) {
                            Text("\(selected.value)")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(5)
                                .background(Color(.systemBackground))
                                .cornerRadius(5)
                        }
                }
            }
            .frame(height: 300)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    guard let plotFrame = proxy.plotFrame else { return }
                                    let x = value.location.x - geometry[plotFrame].origin.x
                                    guard x >= 0, x < proxy.plotSize.width else { return }

                                    let xPosition = x / proxy.plotSize.width
                                    let index = Int(xPosition * CGFloat(viewModel.chartData.count))
                                    guard index >= 0, index < viewModel.chartData.count else { return }

                                    selectedDataPoint = (viewModel.chartData[index].date, viewModel.chartData[index].value)
                                }
                                .onEnded { _ in
                                    // Keep the selection visible
                                }
                        )
                }
            }
            .padding()

            // Chart type selector
            HStack {
                Button {
                    viewModel.chartDisplayType = .bar
                } label: {
                    Text("Bar")
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(viewModel.chartDisplayType == .bar ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.chartDisplayType == .bar ? .white : .primary)
                        .cornerRadius(8)
                }

                Button {
                    viewModel.chartDisplayType = .line
                } label: {
                    Text("Line")
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(viewModel.chartDisplayType == .line ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.chartDisplayType == .line ? .white : .primary)
                        .cornerRadius(8)
                }

                Spacer()

                Button {
                    selectedDataPoint = nil
                } label: {
                    Text("Clear Selection")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
        }
    }

    private var trendAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Trend Analysis")
                .font(.headline)
                .padding(.horizontal)

            // Trend cards
            VStack(spacing: 15) {
                TrendCard(
                    title: "Weekly Trend",
                    description: viewModel.weeklyTrendDescription,
                    icon: viewModel.weeklyTrendIcon,
                    color: viewModel.weeklyTrendColor
                )

                TrendCard(
                    title: "Pattern Detection",
                    description: viewModel.patternDescription,
                    icon: "chart.xyaxis.line",
                    color: .purple
                )

                TrendCard(
                    title: "Goal Progress",
                    description: viewModel.goalProgressDescription,
                    icon: "target",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundColor(.blue)

                Text("AI-Powered Insights")
                    .font(.headline)
                    .foregroundColor(.blue)

                Spacer()

                if viewModel.isLoadingInsights {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)

            Text("Personalized analysis based on your activity data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            if viewModel.isLoadingInsights {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Analyzing your data...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
            } else if viewModel.insights.isEmpty {
                HStack {
                    Spacer()
                    Text("No insights available for this data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                    Spacer()
                }
                .padding()
            } else {
                ForEach(viewModel.insights, id: \.id) { insight in
                    ChartInsightCard(insight: insight)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct TrendCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ChartInsightCard: View {
    let insight: ChartInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack(spacing: 10) {
                // Icon in a circle
                Image(systemName: insight.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(insight.color)
                    .clipShape(Circle())

                // Title with insight type badge
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(insight.type.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(insight.color.opacity(0.2))
                        .foregroundColor(insight.color)
                        .cornerRadius(4)
                }
            }

            Divider()
                .padding(.vertical, 4)

            // Description
            Text(insight.description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Recommendation section if available
            if let recommendation = insight.recommendation {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)

                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Preview
struct ChartDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChartDetailView(chartType: .oneWeek, title: "Weekly Steps")
        }
    }
}
