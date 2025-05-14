//
//  AddActivityView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/15/25.
//

import SwiftUI

struct AddActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel

    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var amount: String = ""
    @State private var selectedIcon: String = "figure.walk"
    @State private var selectedColor: Color = .blue

    // Available icons for activities
    private let icons = [
        "figure.walk", "figure.run", "figure.hiking", "figure.outdoor.cycle",
        "figure.pool.swim", "figure.strengthtraining.traditional", "figure.mind.and.body",
        "heart.fill", "flame.fill", "bolt.fill", "drop.fill", "bed.double.fill"
    ]

    // Available colors
    private let colors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .teal, .indigo
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Title", text: $title)
                    TextField("Subtitle (e.g., Goal: 10,000 steps)", text: $subtitle)
                    TextField("Amount (e.g., 5,000)", text: $amount)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(icon == selectedIcon ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(icon == selectedIcon ? selectedColor : Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 5)
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
                    ActivityCard(activity: Activity(
                        title: title.isEmpty ? "Activity Title" : title,
                        subTitle: subtitle.isEmpty ? "Subtitle" : subtitle,
                        image: selectedIcon,
                        tinColor: selectedColor,
                        amount: amount.isEmpty ? "0" : amount
                    ))
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    Button("Add") {
                        addActivity()
                    }
                    .foregroundColor(title.isEmpty || amount.isEmpty ? .gray : .blue)
                    .disabled(title.isEmpty || amount.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
    }

    private func addActivity() {
        let newActivity = Activity(
            title: title,
            subTitle: subtitle.isEmpty ? "Today" : subtitle,
            image: selectedIcon,
            tinColor: selectedColor,
            amount: amount
        )

        viewModel.addActivity(newActivity)
        dismiss()
    }
}

#Preview {
    AddActivityView(viewModel: HomeViewModel())
}
