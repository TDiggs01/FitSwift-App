//
//  ChatView.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Binding var selectedTab: String
    
    init(selectedTab: Binding<String>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Ask about your fitness...", text: $viewModel.currentInput)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.leading)
                    
                    Button {
                        viewModel.sendMessage(viewModel.currentInput)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("FitSwiftRed"))
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading || viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Fitness Assistant")
            .onAppear {
                if viewModel.messages.isEmpty {
                    // Add welcome message if needed
                    // The welcome message is already added in the ViewModel's init
                }
            }
        }
    }
}

#Preview {
    ChatView(selectedTab: .constant("Chat"))
}
