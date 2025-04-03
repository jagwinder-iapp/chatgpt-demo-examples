//
//  ChatViewModel.swift
//  ChatDemo
//
//  Created by iapp on 02/04/25.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [] {
        didSet { saveMessages() }
    }
    @Published var inputText: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "chatMessages"
    
    init() {
        loadMessages()
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMessage = Message(text: inputText, isUser: true)
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        fetchOpenAIResponse(for: userInput)
    }
    
    private func fetchOpenAIResponse(for message: String) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [["role": "user", "content": message]],
            "temperature": 0.7
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Constants.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                if let text = response.choices.first?.message.content {
                    self.messages.append(Message(text: text, isUser: false))
                }
            })
            .store(in: &cancellables)
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadMessages() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Message].self, from: savedData) {
            messages = decoded
        }
    }
}
