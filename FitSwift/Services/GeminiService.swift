//
//  GeminiService.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/11/25.
//

import Foundation
import GoogleGenerativeAI
import SwiftUI

// Define the tool response structure
struct ToolResponse: Codable, Identifiable {
    let id = UUID()
    let toolType: ToolType
    let chartType: ChartType?
    let timeRange: TimeRange?
    let metric: MetricType?
    let title: String?
    let description: String?
    
    enum ToolType: String, Codable {
        case showChart
        case showActivity
        case showWorkoutHistory
    }
    
    enum ChartType: String, Codable {
        case bar
        case line
        case pie
    }
    
    enum TimeRange: String, Codable {
        case day
        case week
        case month
        case year
    }
    
    enum MetricType: String, Codable {
        case steps
        case calories
        case exercise
        case workouts
        case standHours
    }
}

class GeminiService {
    static let shared = GeminiService()
    private let model: GenerativeModel
    
    private init() {
        // Create the model configuration
        let config = GenerationConfig(
            temperature: 0.7,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 2048
        )
        
        // Create the model
        model = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: APIKey.default,
            generationConfig: config,
            safetySettings: [],
            systemInstruction: """
            You are a fitness assistant helping with workout advice, step tracking, and general fitness information.
            
            You have access to tools that can show charts and visualizations. When the user asks to see their data visually or asks for charts/graphs, use the appropriate tool:
            - Use showChart to display fitness metrics as charts
            - Use showActivity to display the user's activity rings
            - Use showWorkoutHistory to show recent workouts
            
            For showChart, you need to specify:
            - chartType: "bar", "line", or "pie"
            - timeRange: "day", "week", "month", or "year"
            - metric: "steps", "calories", "exercise", "workouts", or "standHours"
            - title: A title for the chart
            - description: A brief description of what the chart shows
            
            For showWorkoutHistory, you need to specify:
            - timeRange: "week", "month", or "year"
            
            For showActivity, no parameters are needed.
            
            Example function call for showChart:
            {
              "name": "showChart",
              "arguments": {
                "chartType": "bar",
                "timeRange": "week",
                "metric": "steps",
                "title": "Weekly Steps",
                "description": "Your step count over the past week"
              }
            }
            
            Example function call for showActivity:
            {
              "name": "showActivity",
              "arguments": {}
            }
            
            Example function call for showWorkoutHistory:
            {
              "name": "showWorkoutHistory",
              "arguments": {
                "timeRange": "week"
              }
            }
            """
        )
    }
    
    func generateResponse(prompt: String) async throws -> (String, [ToolResponse]?) {
        // Generate content
        let response = try await model.generateContent(prompt)
        let responseText = response.text ?? ""
        
        var toolResponses: [ToolResponse]?
        
        // First try to extract function calls from the response parts
        if let candidates = response.candidates.first {
            let parts = candidates.content.parts
            let functionCalls = parts.compactMap { part -> FunctionCall? in
                if case let .functionCall(functionCall) = part {
                    return functionCall
                }
                return nil
            }
            
            if !functionCalls.isEmpty {
                // Process tool calls
                toolResponses = []
                
                for functionCall in functionCalls {
                    if let toolResponse = processToolCall(functionCall) {
                        toolResponses?.append(toolResponse)
                    }
                }
            }
        }
        
        // If no function calls were found in the response parts, try to extract them from the text
        if (toolResponses == nil || toolResponses?.isEmpty == true) {
            // Check for both tool_code and json patterns
            if responseText.contains("tool_code") {
                toolResponses = extractToolResponsesFromText(responseText, prefix: "tool_code")
            } else if responseText.contains("json") {
                toolResponses = extractToolResponsesFromText(responseText, prefix: "json")
            }
        }
        
        // Clean up the response text by removing the tool_code or json blocks
        let cleanedText = cleanResponseText(responseText)
        
        return (cleanedText, toolResponses)
    }
    
    private func processToolCall(_ functionCall: FunctionCall) -> ToolResponse? {
        let functionName = functionCall.name
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: functionCall.args)
            
            switch functionName {
            case "showChart":
                let decoder = JSONDecoder()
                let params = try decoder.decode([String: String].self, from: jsonData)
                
                return ToolResponse(
                    toolType: .showChart,
                    chartType: ToolResponse.ChartType(rawValue: params["chartType"] ?? "bar"),
                    timeRange: ToolResponse.TimeRange(rawValue: params["timeRange"] ?? "week"),
                    metric: ToolResponse.MetricType(rawValue: params["metric"] ?? "steps"),
                    title: params["title"],
                    description: params["description"]
                )
                
            case "showActivity":
                return ToolResponse(
                    toolType: .showActivity,
                    chartType: nil,
                    timeRange: nil,
                    metric: nil,
                    title: nil,
                    description: nil
                )
                
            case "showWorkoutHistory":
                let decoder = JSONDecoder()
                let params = try decoder.decode([String: String].self, from: jsonData)
                
                return ToolResponse(
                    toolType: .showWorkoutHistory,
                    chartType: nil,
                    timeRange: ToolResponse.TimeRange(rawValue: params["timeRange"] ?? "week"),
                    metric: nil,
                    title: nil,
                    description: nil
                )
                
            default:
                return nil
            }
        } catch {
            print("Error processing tool call: \(error)")
            return nil
        }
    }
    
    func buildPrompt(userMessage: String, fitnessContext: String, conversationHistory: String) -> String {
        return """
            User's fitness context: \(fitnessContext)
            Conversation history: \(conversationHistory)
            User's latest message: \(userMessage)
        """
    }

    // Updated method to extract tool responses from text with different prefixes
    private func extractToolResponsesFromText(_ text: String, prefix: String) -> [ToolResponse]? {
        // Look for pattern with the specified prefix
        let pattern = "\(prefix)\\s*\\{([^}]+)\\}"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        guard let regex = regex else { return nil }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if matches.isEmpty {
            return nil
        }
        
        var toolResponses: [ToolResponse] = []
        
        for match in matches {
            if match.numberOfRanges > 1 {
                let jsonRange = match.range(at: 1)
                var jsonString = nsString.substring(with: jsonRange)
                
                // Clean up the JSON string
                jsonString = jsonString.replacingOccurrences(of: "\n", with: " ")
                jsonString = jsonString.replacingOccurrences(of: "\\", with: "")
                
                // Try to parse the JSON
                if let toolResponse = parseToolResponseFromText(jsonString) {
                    toolResponses.append(toolResponse)
                }
            }
        }
        
        return toolResponses.isEmpty ? nil : toolResponses
    }

    // Improved method to parse tool response from text
    private func parseToolResponseFromText(_ jsonString: String) -> ToolResponse? {
        // Extract the name and arguments from the text directly
        let namePattern = "\"name\"\\s*:\\s*\"([^\"]+)\""
        let nameRegex = try? NSRegularExpression(pattern: namePattern, options: [])
        
        guard let nameRegex = nameRegex,
              let nameMatch = nameRegex.firstMatch(in: jsonString, options: [], range: NSRange(location: 0, length: jsonString.count)) else {
            return nil
        }
        
        let nsString = jsonString as NSString
        let nameRange = nameMatch.range(at: 1)
        let name = nsString.substring(with: nameRange)
        
        // Extract arguments based on the tool type
        switch name {
        case "showChart":
            // Extract chart parameters
            let chartType = extractStringValue(from: jsonString, forKey: "chartType") ?? "bar"
            let timeRange = extractStringValue(from: jsonString, forKey: "timeRange") ?? "week"
            let metric = extractStringValue(from: jsonString, forKey: "metric") ?? "steps"
            let title = extractStringValue(from: jsonString, forKey: "title")
            let description = extractStringValue(from: jsonString, forKey: "description")
            
            return ToolResponse(
                toolType: .showChart,
                chartType: ToolResponse.ChartType(rawValue: chartType),
                timeRange: ToolResponse.TimeRange(rawValue: timeRange),
                metric: ToolResponse.MetricType(rawValue: metric),
                title: title,
                description: description
            )
            
        case "showActivity":
            return ToolResponse(
                toolType: .showActivity,
                chartType: nil,
                timeRange: nil,
                metric: nil,
                title: nil,
                description: nil
            )
            
        case "showWorkoutHistory":
            let timeRange = extractStringValue(from: jsonString, forKey: "timeRange") ?? "week"
            
            return ToolResponse(
                toolType: .showWorkoutHistory,
                chartType: nil,
                timeRange: ToolResponse.TimeRange(rawValue: timeRange),
                metric: nil,
                title: nil,
                description: nil
            )
            
        default:
            return nil
        }
    }

    // Helper method to extract string values from JSON text
    private func extractStringValue(from jsonString: String, forKey key: String) -> String? {
        let pattern = "\"\(key)\"\\s*:\\s*\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let regex = regex,
              let match = regex.firstMatch(in: jsonString, options: [], range: NSRange(location: 0, length: jsonString.count)) else {
            return nil
        }
        
        let nsString = jsonString as NSString
        let valueRange = match.range(at: 1)
        return nsString.substring(with: valueRange)
    }

    // Updated method to clean response text by removing both tool_code and json blocks
    private func cleanResponseText(_ text: String) -> String {
        var cleanedText = text
        
        // Remove tool_code blocks
        let toolCodePattern = "tool_code\\s*\\{[^}]+\\}"
        if let regex = try? NSRegularExpression(pattern: toolCodePattern, options: [.dotMatchesLineSeparators]) {
            let nsString = cleanedText as NSString
            let range = NSRange(location: 0, length: nsString.length)
            cleanedText = regex.stringByReplacingMatches(in: cleanedText, options: [], range: range, withTemplate: "")
        }
        
        // Remove json blocks
        let jsonPattern = "json\\s*\\{[^}]+\\}"
        if let regex = try? NSRegularExpression(pattern: jsonPattern, options: [.dotMatchesLineSeparators]) {
            let nsString = cleanedText as NSString
            let range = NSRange(location: 0, length: nsString.length)
            cleanedText = regex.stringByReplacingMatches(in: cleanedText, options: [], range: range, withTemplate: "")
        }
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


