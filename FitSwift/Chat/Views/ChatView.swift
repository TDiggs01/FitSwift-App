//
//  ChatView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Fitness Assistant")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Image("fitness_chatbot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.fitSwiftGreen, lineWidth: 2)
                    )
            }
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) {
                        message in MessageBubble(message: message)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                TextField("Ask about your fitness...", text: $messageText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                Button {
                    viewModel.sendMessage(messageText)
                    messageText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.fitSwiftRed)
                        .cornerRadius(50)
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    ChatView()
}
