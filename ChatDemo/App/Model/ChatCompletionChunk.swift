//
//  ChatCompletionChunk.swift
//  ChatDemo
//
//  Created by iapp on 02/04/25.
//

import Foundation

// MARK: - DeltaResponse
struct ChatCompletionChunk: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let serviceTier: String?
    let systemFingerprint: String?
    let choices: [Choice]?

    enum CodingKeys: String, CodingKey {
        case id, object, created, model
        case serviceTier = "service_tier"
        case systemFingerprint = "system_fingerprint"
        case choices
    }

    struct Choice: Codable {
        let index: Int?
        let delta: Delta?
        let logprobs: String?
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index, delta, logprobs
            case finishReason = "finish_reason"
        }

        struct Delta: Codable {
            let role: String?
            let content: String?
            let refusal: String?
        }
    }
}
