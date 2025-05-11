//
//  Message.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//

import Foundation
import SwiftUI

struct Message: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isUser: Bool
    let toolResponses: [ToolResponse]?
    
    init(id: UUID = UUID(), text: String, isUser: Bool, toolResponses: [ToolResponse]? = nil) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.toolResponses = toolResponses
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isUser == rhs.isUser
    }
}
