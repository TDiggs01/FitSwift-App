//
//  ChartsView.swift
//  FitSwift
//
//  Created by csuftitan on 4/26/25.
//

import SwiftUI
import Charts

struct ChartsView: View {
    @StateObject var viewModel = ChartsViewModel()
    @State var selectedChart: ChartOptions = .oneWeek

    // Helper method to get chart title
    func getChartTitle(for chartType: ChartOptions) -> String {
        switch chartType {
        case .oneWeek:
            return "Weekly Steps"
        case .oneMonth:
            return "Monthly Steps"
        case .threeMonth:
            return "Quarterly Steps"
        case .yearToDate:
            return "Year-to-Date Steps"
        case .oneYear:
            return "Annual Steps"
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
            Text("Charts")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            // Chart
            ZStack {
                switch selectedChart {
                case .oneWeek:
                    VStack {
                        ChartDataView(average: viewModel.oneWeekAverage, total: viewModel.oneWeekTotal)

                        Chart {
                            ForEach(viewModel.mockWeekChartData) { data in
                                BarMark(x: .value(data.date.formatted(), data.date, unit: .day), y: .value("Steps", data.count))
                            }
                        }
                    }
                case .oneMonth:
                    VStack {
                        ChartDataView(average: viewModel.oneMonthAverage, total: viewModel.oneMonthTotal)
                        Chart {
                            ForEach(viewModel.mockOneMonthData) { data in
                                BarMark(x: .value(data.date.formatted(), data.date, unit: .day), y: .value("Steps", data.count))
                            }
                        }
                    }
                case .threeMonth:
                    VStack {
                        ChartDataView(average: viewModel.threeMonthAverage, total: viewModel.threeMonthTotal)
                        Chart {
                            ForEach(viewModel.mockThreeMonthData) { data in
                                BarMark(x: .value(data.date.formatted(), data.date, unit: .day), y: .value("Steps", data.count))
                            }
                        }
                    }
                case .yearToDate:
                    VStack {
                        ChartDataView(average: viewModel.ytdAverage, total: viewModel.ytdTotal)
                        Chart {
                            ForEach(viewModel.ytdChartData) { data in
                                BarMark(x: .value(data.date.formatted(), data.date, unit: .month), y: .value("Steps", data.count))
                            }
                        }
                    }
                case .oneYear:
                    VStack {
                        ChartDataView(average: viewModel.oneYearAverage, total: viewModel.oneYearTotal)
                        Chart {
                            ForEach(viewModel.oneYearChartData) { data in
                                BarMark(x: .value(data.date.formatted(), data.date, unit: .month), y: .value("Steps", data.count))
                            }
                        }
                    }
                }
            }
            .foregroundColor(.red)
            .frame(maxHeight: 450)
            .padding(.horizontal)

            // Chart Buttons
            HStack {
                ForEach(ChartOptions.allCases, id: \.rawValue) { option in
                    Button(option.rawValue) {
                        withAnimation {
                            selectedChart = option
                        }
                    }
                    .padding()
                    .foregroundColor(selectedChart == option ? .white : .red)
                    .background(selectedChart == option ? .red : .white)
                    .cornerRadius(10)
                }
            }

            // View Details Button
            NavigationLink(destination: ChartDetailView(chartType: selectedChart, title: getChartTitle(for: selectedChart))) {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("View Detailed Analysis")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 20)
            }

        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    ChartsView()
}
