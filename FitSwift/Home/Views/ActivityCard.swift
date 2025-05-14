//
//  ActivityCard.swift
//  FitSwift
//
//  Created by csuftitan on 4/14/25.
//

import SwiftUI

struct ActivityCard: View {
    @State var activity: Activity
    var isEditMode: Bool = false
    var onDelete: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)

            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)
                            .font(.headline)

                        Text(activity.subTitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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

                    Image(systemName: activity.image)
                        .foregroundColor(activity.tinColor)
                        .font(.title2)
                }

                Text(activity.amount)
                    .font(.title)
                    .bold(true)
                    .padding()

            }
            .padding()

        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isEditMode ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}


#Preview {
    ActivityCard(activity: Activity(title: "Today Steps", subTitle: "Goal: 12,000 steps", image: "figure.walk", tinColor: .green, amount: "6,000"))
}
