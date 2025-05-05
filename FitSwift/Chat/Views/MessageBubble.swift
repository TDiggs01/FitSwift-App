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
        HStack {
            if !message.isUser {
                Image("fitness_chatbot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.fitSwiftRed : Color(.systemGray5))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(20)
            
            if !message.isUser {
                Spacer()
            }
            else {
                Spacer()
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    MessageBubble(message: Message(id: UUID(), text: "Hello, how can I help with your fitness goal?", isUser: false))
}
