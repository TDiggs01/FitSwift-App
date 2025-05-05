//
//  ChatViewModel.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//


import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let healthManager = HealthManager.shared
    
    init() {
        // Add welcome message
        let welcomeMessage = Message(
            id: UUID(),
            text: "Hello! I'm your fitness assistant. Ask me about your workouts, steps, or for fitness advice.",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = Message(id: UUID(), text: text, isUser: true)
        messages.append(userMessage)
        
        // Process the message and generate a response
        generateResponse(to: text)
    }
    
    private func generateResponse(to text: String) {
        // In a real implementation, this would call the Gemini API
        // For now, we'll use a simple rule-based system
        
        let lowercaseText = text.lowercased()
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            var responseText = ""
            
            if lowercaseText.contains("step") {
                self.fetchStepsAndRespond(query: lowercaseText)
                return
            } else if lowercaseText.contains("workout") || lowercaseText.contains("exercise") {
                self.fetchWorkoutsAndRespond()
                return
            } else if lowercaseText.contains("calorie") {
                self.fetchCaloriesAndRespond()
                return
            } else if lowercaseText.contains("advice") || lowercaseText.contains("tip") {
                responseText = self.getRandomFitnessTip()
            } else {
                responseText = "I'm here to help with your fitness journey. You can ask about your steps, workouts, calories, or request fitness advice."
            }
            
            let assistantMessage = Message(id: UUID(), text: responseText, isUser: false)
            self.messages.append(assistantMessage)
        }
    }
    
    private func fetchStepsAndRespond(query: String) {
        healthManager.fetchTodaySteps { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                var responseText = ""
                
                switch result {
                case .success(let activity):
                    responseText = "Today you've taken \(activity.amount) steps. "
                    
                    if let stepCount = Int(activity.amount.replacingOccurrences(of: ",", with: "")) {
                        if stepCount < 5000 {
                            responseText += "You're a bit behind today. Try to get some more steps in!"
                        } else if stepCount < 8000 {
                            responseText += "You're doing well, but try to reach 10,000 steps for optimal health benefits."
                        } else {
                            responseText += "Great job! You're very active today."
                        }
                    }
                    
                case .failure:
                    responseText = "I couldn't retrieve your step data. Make sure Health permissions are enabled."
                }
                
                let assistantMessage = Message(id: UUID(), text: responseText, isUser: false)
                self.messages.append(assistantMessage)
            }
        }
    }
    
    private func fetchWorkoutsAndRespond() {
        // In a real implementation, this would fetch actual workout data
        let responseText = "Based on your recent workouts, you've been most consistent with running. Your average workout duration is 45 minutes, which is excellent for cardiovascular health."
        
        let assistantMessage = Message(id: UUID(), text: responseText, isUser: false)
        self.messages.append(assistantMessage)
    }
    
    private func fetchCaloriesAndRespond() {
        healthManager.fetchTodayCaloriesBurned { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                var responseText = ""
                
                switch result {
                case .success(let calories):
                    responseText = "Today you've burned approximately \(Int(calories)) calories. "
                    
                    if calories < 300 {
                        responseText += "Try to increase your activity level to burn more calories."
                    } else if calories < 600 {
                        responseText += "You're making good progress toward your daily activity goals."
                    } else {
                        responseText += "Great job! You're very active today."
                    }
                    
                case .failure:
                    responseText = "I couldn't retrieve your calorie data. Make sure Health permissions are enabled."
                }
                
                let assistantMessage = Message(id: UUID(), text: responseText, isUser: false)
                self.messages.append(assistantMessage)
            }
        }
    }
    
    private func getRandomFitnessTip() -> String {
        let tips = [
            "Try to get at least 150 minutes of moderate aerobic activity or 75 minutes of vigorous aerobic activity a week.",
            "Strength training exercises for all major muscle groups at least twice a week can help improve overall fitness.",
            "Stay hydrated! Drink water before, during, and after your workout.",
            "Make sure to include rest days in your fitness routine to allow your body to recover.",
            "Consistency is key for fitness results. Even short daily workouts are better than occasional intense sessions.",
            "Consider tracking your workouts to monitor progress and stay motivated.",
            "Mix up your routine to prevent plateaus and keep exercise interesting.",
            "Proper form is more important than the amount of weight you lift or how many reps you do."
        ]
        
        return tips.randomElement() ?? tips[0]
    }
}
