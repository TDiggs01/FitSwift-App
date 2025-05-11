//
//  MessageBubble.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            HStack {
                if message.isUser {
                    Spacer()
                    Text(message.text)
                        .padding(12)
                        .background(Color.fitSwiftRed)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                } else {
                    HStack(alignment: .top) {
                        Image("fitness_chatbot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.fitSwiftRed)
                            .padding(4)
                        
                        Text(LocalizedStringKey(message.text))
                            .padding(12)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                    }
                    Spacer()
                }
            }
            
            // Display tool responses if any
            if let toolResponses = message.toolResponses, !toolResponses.isEmpty, !message.isUser {
                ForEach(toolResponses) { toolResponse in
                    ToolResponseView(toolResponse: toolResponse)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(message: Message(
            id: UUID(),
            text: "Hello, how can I help with your fitness goal?",
            isUser: false
        ))
        
        MessageBubble(message: Message(
            id: UUID(),
            text: "Show me my steps for the week",
            isUser: true
        ))
        
        MessageBubble(message: Message(
            id: UUID(),
            text: "Here's your step count for the past week:",
            isUser: false,
            toolResponses: [
                ToolResponse(
                    toolType: .showChart,
                    chartType: .bar,
                    timeRange: .week,
                    metric: .steps,
                    title: "Weekly Steps",
                    description: "Your step count over the past week"
                )
            ]
        ))
    }
    .padding()
}
