import SwiftUI
import Charts

struct ToolResponseView: View {
    let toolResponse: ToolResponse
    @ObservedObject var viewModel = ToolResponseViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch toolResponse.toolType {
            case .showChart:
                chartView
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

            case .showActivity:
                activityRingsView
                    .frame(height: 150)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

            case .showWorkoutHistory:
                workoutHistoryView
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            if let description = toolResponse.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    // Chart view based on the requested chart type and metric
    private var chartView: some View {
        VStack(alignment: .leading) {
            Text(toolResponse.title ?? "Fitness Data")
                .font(.headline)

            if let metric = toolResponse.metric, let chartType = toolResponse.chartType {
                switch chartType {
                case .bar:
                    barChartView(for: metric)
                case .line:
                    lineChartView(for: metric)
                case .pie:
                    pieChartView(for: metric)
                }
            } else {
                // Fallback to a default chart
                barChartView(for: .steps)
            }
        }
    }

    // Bar chart for different metrics
    private func barChartView(for metric: ToolResponse.MetricType) -> some View {
        let data = getChartData(for: metric)

        return Chart(data, id: \.id) { item in
            BarMark(
                x: .value("Date", item.date, unit: .day),
                y: .value(metric.rawValue.capitalized, item.value)
            )
            .foregroundStyle(Color.red.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }

    // Line chart for different metrics
    private func lineChartView(for metric: ToolResponse.MetricType) -> some View {
        let data = getChartData(for: metric)

        return Chart(data, id: \.id) { item in
            LineMark(
                x: .value("Date", item.date, unit: .day),
                y: .value(metric.rawValue.capitalized, item.value)
            )
            .foregroundStyle(Color.red)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Date", item.date, unit: .day),
                y: .value(metric.rawValue.capitalized, item.value)
            )
            .foregroundStyle(Color.red)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }

    // Pie chart for different metrics
    private func pieChartView(for metric: ToolResponse.MetricType) -> some View {
        let data = getChartData(for: metric)

        return Chart(data, id: \.id) { item in
            SectorMark(
                angle: .value(item.date.formatted(.dateTime.weekday(.abbreviated)), item.value),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(by: .value("Day", item.date.formatted(.dateTime.weekday(.abbreviated))))
            .annotation(position: .overlay) {
                Text("\(Int(item.value))")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .chartLegend(position: .bottom, alignment: .center)
    }

    // Activity rings view
    private var activityRingsView: some View {
        VStack(alignment: .leading) {
            Text("Activity Rings")
                .font(.headline)

            HStack(spacing: 20) {
                // Move ring
                ZStack {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: min(CGFloat(viewModel.movePercentage), 1.0))
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack {
                        Text("\(Int(viewModel.movePercentage * 100))%")
                            .font(.caption)
                        Text("Move")
                            .font(.caption2)
                    }
                }

                // Exercise ring
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: min(CGFloat(viewModel.exercisePercentage), 1.0))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack {
                        Text("\(Int(viewModel.exercisePercentage * 100))%")
                            .font(.caption)
                        Text("Exercise")
                            .font(.caption2)
                    }
                }

                // Stand ring
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: min(CGFloat(viewModel.standPercentage), 1.0))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack {
                        Text("\(Int(viewModel.standPercentage * 100))%")
                            .font(.caption)
                        Text("Stand")
                            .font(.caption2)
                    }
                }
            }
            .padding()
        }
    }

    // Workout history view
    private var workoutHistoryView: some View {
        VStack(alignment: .leading) {
            Text("Recent Workouts")
                .font(.headline)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.recentWorkouts, id: \.id) { workout in
                        HStack {
                            Image(systemName: workout.image)
                                .foregroundColor(workout.tinColor)
                                .frame(width: 30, height: 30)

                            VStack(alignment: .leading) {
                                Text(workout.title)
                                    .font(.subheadline)
                                    .bold()
                                Text(workout.date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(workout.duration)
                                    .font(.subheadline)
                                Text(workout.calories)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    // Helper function to get chart data based on metric type
    private func getChartData(for metric: ToolResponse.MetricType) -> [ChartDataPoint] {
        switch metric {
        case .steps:
            return viewModel.stepsData
        case .calories:
            return viewModel.caloriesData
        case .exercise:
            return viewModel.exerciseData
        case .workouts:
            return viewModel.workoutsData
        case .standHours:
            return viewModel.standData
        }
    }
}


// ToolResponseViewModel to provide data for the charts
class ToolResponseViewModel: ObservableObject {
    @Published var stepsData: [ChartDataPoint] = []
    @Published var caloriesData: [ChartDataPoint] = []
    @Published var exerciseData: [ChartDataPoint] = []
    @Published var workoutsData: [ChartDataPoint] = []
    @Published var standData: [ChartDataPoint] = []

    @Published var movePercentage: Double = 0.7
    @Published var exercisePercentage: Double = 0.85
    @Published var standPercentage: Double = 0.5

    @Published var recentWorkouts: [Workout] = []

    private let healthManager = HealthManager.shared

    init() {
        loadMockData()
        fetchRecentWorkouts()
    }

    private func loadMockData() {
        // Generate mock data for the past week
        let calendar = Calendar.current
        let today = Date()

        // Steps data (7000-15000 range)
        stepsData = (0..<7).map { day in
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            return ChartDataPoint(date: date, value: Double.random(in: 7000...15000))
        }

        // Calories data (300-700 range)
        caloriesData = (0..<7).map { day in
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            return ChartDataPoint(date: date, value: Double.random(in: 300...700))
        }

        // Exercise data (20-70 minutes range)
        exerciseData = (0..<7).map { day in
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            return ChartDataPoint(date: date, value: Double.random(in: 20...70))
        }

        // Workouts data (0-2 workouts per day)
        workoutsData = (0..<7).map { day in
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            return ChartDataPoint(date: date, value: Double.random(in: 0...2).rounded())
        }

        // Stand hours data (6-12 hours range)
        standData = (0..<7).map { day in
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            return ChartDataPoint(date: date, value: Double.random(in: 6...12).rounded())
        }

        // Update activity ring percentages
        movePercentage = Double.random(in: 0.5...1.0)
        exercisePercentage = Double.random(in: 0.4...1.0)
        standPercentage = Double.random(in: 0.3...1.0)
    }

    func fetchRecentWorkouts() {
        healthManager.fetchWorkoutsForMonth(month: Date()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let workouts):
                    self?.recentWorkouts = workouts
                case .failure:
                    // Use mock data if real data fails
                    self?.recentWorkouts = [
                        Workout(id: 1, title: "Running", image: "figure.run", tinColor: .green, duration: "32 mins", date: Date().formatWorkoutDate(), calories: "320 kcal"),
                        Workout(id: 2, title: "Strength Training", image: "figure.strengthtraining.traditional", tinColor: .orange, duration: "45 mins", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())?.formatWorkoutDate() ?? "", calories: "280 kcal"),
                        Workout(id: 3, title: "Basketball", image: "figure.basketball", tinColor: .red, duration: "60 mins", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())?.formatWorkoutDate() ?? "", calories: "450 kcal")
                    ]
                }
            }
        }
    }
}

// Preview provider
struct ToolResponseView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToolResponseView(toolResponse: ToolResponse(
                toolType: .showChart,
                chartType: .bar,
                timeRange: .week,
                metric: .steps,
                title: "Weekly Steps",
                description: "Your step count over the past week"
            ))

            ToolResponseView(toolResponse: ToolResponse(
                toolType: .showActivity,
                chartType: nil,
                timeRange: nil,
                metric: nil,
                title: nil,
                description: "Your activity rings for today"
            ))

            ToolResponseView(toolResponse: ToolResponse(
                toolType: .showWorkoutHistory,
                chartType: nil,
                timeRange: .week,
                metric: nil,
                title: nil,
                description: "Your recent workouts"
            ))
        }
        .padding()
    }
}
