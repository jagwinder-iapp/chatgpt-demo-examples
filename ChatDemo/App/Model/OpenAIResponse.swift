//
//  OpenAIResponse.swift
//  ChatDemo
//
//  Created by iapp on 02/04/25.
//


struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}