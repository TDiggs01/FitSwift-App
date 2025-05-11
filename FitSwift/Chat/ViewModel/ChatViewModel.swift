//
//  ChatViewModel.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//


import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var selectedTab: String = "Chat"
    @Published var currentInput: String = ""
    
    private let geminiService = GeminiService.shared
    private let healthManager = HealthManager.shared
    
    
    init() {
        // Add welcome message
        let welcomeMessage = Message(
            id: UUID(),
            text: "Hello! I'm your fitness assistant. Ask me about your workouts, steps, or for fitness advice. I can also show charts and visualizations of your data - just ask!",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = Message(id: UUID(), text: text, isUser: true)
        messages.append(userMessage)
        
        // Clear the input field
        currentInput = ""
        
        // Process the message and generate a response
        generateResponse(to: text)
    }

    // Add a method that accepts the selectedTab binding
    func sendMessage(selectedTab: Binding<String>) {
        // Get the text from currentInput
        let text = currentInput
        
        // Clear the input field
        currentInput = ""
        
        // Add user message
        let userMessage = Message(id: UUID(), text: text, isUser: true)
        messages.append(userMessage)
        
        // Store the binding for later use
        self.selectedTab = selectedTab.wrappedValue
        
        // Process the message and generate a response
        generateResponse(to: text)
    }
    
    private func generateResponse(to text: String) {
        isLoading = true
        
        Task {
            do {
                // gather fitness context and build conversation history
                let fitnessContext = await gatherFitnessContext()
                let conversationHistory = buildConversationHistory()
                
                // build the prompt using the service
                let prompt = geminiService.buildPrompt(
                    userMessage: text,
                    fitnessContext: fitnessContext,
                    conversationHistory: conversationHistory
                )
                
                // Get response and any tool calls
                let (responseText, toolResponses) = try await geminiService.generateResponse(prompt: prompt)
                
                // Handle tool responses if any
                if let toolResponses = toolResponses, !toolResponses.isEmpty {
                    for toolResponse in toolResponses {
                        handleToolResponse(toolResponse)
                    }
                }
                
                // Update UI on the main thread
                await MainActor.run {
                    isLoading = false
                    let responseMessage = Message(
                        id: UUID(),
                        text: responseText,
                        isUser: false,
                        toolResponses: toolResponses
                    )
                    messages.append(responseMessage)
                }
            } catch {
                // Simplified error handling like the working example
                await MainActor.run {
                    isLoading = false
                    let errorMessage = Message(
                        id: UUID(),
                        text: "Something went wrong: \(error.localizedDescription)",
                        isUser: false
                    )
                    messages.append(errorMessage)
                }
            }
        }
    }
    
    private func handleToolResponse(_ toolResponse: ToolResponse) {
        // Handle different tool responses
        switch toolResponse.toolType {
        case .showChart:
            // Switch to Charts tab and set the appropriate chart type
            DispatchQueue.main.async {
                self.selectedTab = "Charts"
                
                // You would need to implement a way to communicate with the ChartsView
                // to show the specific chart requested
                NotificationCenter.default.post(
                    name: Notification.Name("ShowChart"),
                    object: nil,
                    userInfo: [
                        "chartType": toolResponse.chartType?.rawValue ?? "bar",
                        "timeRange": toolResponse.timeRange?.rawValue ?? "week",
                        "metric": toolResponse.metric?.rawValue ?? "steps",
                        "title": toolResponse.title ?? "Fitness Data"
                    ]
                )
            }
            
        case .showActivity:
            // Switch to Home tab to show activity rings
            DispatchQueue.main.async {
                self.selectedTab = "Home"
                
                // Notify the HomeView to highlight the activity rings
                NotificationCenter.default.post(
                    name: Notification.Name("ShowActivityRings"),
                    object: nil
                )
            }
            
        case .showWorkoutHistory:
            // Switch to Home tab and scroll to workout history
            DispatchQueue.main.async {
                self.selectedTab = "Home"
                
                // Notify the HomeView to show workout history
                NotificationCenter.default.post(
                    name: Notification.Name("ShowWorkoutHistory"),
                    object: nil,
                    userInfo: [
                        "timeRange": toolResponse.timeRange?.rawValue ?? "week"
                    ]
                )
            }
        }
    }
    
    private func buildConversationHistory() -> String {
        // skip welcome message and maintain last 10 messages to avoid limit excess.
        let relevantMessages = messages.dropFirst().suffix(10)
        
        var history = ""
        for message in relevantMessages {
            let role = message.isUser ? "User" : "Assistant"
            history += "\(role): \(message.text)\n"
        }
        return history
        
    }
    
    private func gatherFitnessContext() async -> String {
        var contextParts: [String] = []
        
        // Get today's steps
        await withCheckedContinuation { continuation in
            healthManager.fetchTodaySteps { result in
                switch result {
                case .success(let activity):
                    contextParts.append("Today's steps: \(activity.amount) out of a goal of 10,000 steps")
                case .failure:
                    contextParts.append("Today's steps: Not available")
                }
                continuation.resume()
            }
        }
        
        // Get calories burned
        await withCheckedContinuation { continuation in
            healthManager.fetchTodayCaloriesBurned { result in
                switch result {
                case .success(let calories):
                    contextParts.append("Calories burned today: \(calories.formattedNumberString()) kcal out of a goal of 600 kcal")
                case .failure:
                    contextParts.append("Calories burned today: Not available")
                }
                continuation.resume()
            }
        }
        
        // Get exercise time
        await withCheckedContinuation { continuation in
            healthManager.fetchTodayExerciseTime { result in
                switch result {
                case .success(let exercise):
                    contextParts.append("Exercise minutes today: \(exercise.formattedNumberString()) minutes out of a goal of 60 minutes")
                case .failure:
                    contextParts.append("Exercise minutes today: Not available")
                }
                continuation.resume()
            }
        }
        
        // Get stand hours
        await withCheckedContinuation { continuation in
            healthManager.fetchTodayStandHours { result in
                switch result {
                case .success(let hours):
                    contextParts.append("Stand hours today: \(hours) hours out of a goal of 12 hours")
                case .failure:
                    contextParts.append("Stand hours today: Not available")
                }
                continuation.resume()
            }
        }
        
        // Get weekly workout stats
        var weeklyWorkoutInfo = "This week's workouts:"
        await withCheckedContinuation { continuation in
            healthManager.fetchCurrentWeekWorkoutStats { result in
                switch result {
                case .success(let activities):
                    if activities.isEmpty {
                        weeklyWorkoutInfo += " No workouts recorded this week."
                    } else {
                        for activity in activities {
                            weeklyWorkoutInfo += "\n- \(activity.title): \(activity.amount)"
                        }
                    }
                case .failure:
                    weeklyWorkoutInfo += " Not available"
                }
                contextParts.append(weeklyWorkoutInfo)
                continuation.resume()
            }
        }
        
        // Get recent workouts
        var workoutInfo = "Recent workouts:"
        await withCheckedContinuation { continuation in
            healthManager.fetchWorkoutsForMonth(month: Date()) { result in
                switch result {
                case .success(let workouts):
                    if workouts.isEmpty {
                        workoutInfo += " None recorded recently."
                    } else {
                        for workout in workouts.prefix(3) {
                            workoutInfo += "\n- \(workout.title) for \(workout.duration) on \(workout.date), burning \(workout.calories)"
                        }
                    }
                case .failure:
                    workoutInfo += " Not available"
                }
                contextParts.append(workoutInfo)
                continuation.resume()
            }
        }
        
        return contextParts.joined(separator: "\n")
    }
}
