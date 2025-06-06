//
//  Message.swift
//  ChatDemo
//
//  Created by iapp on 02/04/25.
//

import Foundation

struct Message: Codable, Identifiable {
    var id = UUID()
    var text: String
    let isUser: Bool
}
