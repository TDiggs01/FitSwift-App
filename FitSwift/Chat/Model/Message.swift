//
//  Message.swift
//  FitSwift
//
//  Created by Nghia Phan on 5/5/25.
//

import Foundation


struct Message: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
}
