//
//  ChatViewModel.swift
//  ChatDemo
//
//  Created by iapp on 02/04/25.
//

import Foundation
import Combine

protocol ChatViewModelDelegate: AnyObject {
    func didReceiveChunk(_ chunk: String)
}

class ChatViewModel: NSObject, ObservableObject, URLSessionDelegate, URLSessionDataDelegate {
    @Published var messages: [Message] = [] {
        didSet { saveMessages() }
    }
    @Published var inputText: String = ""
    @Published var isTyping: Bool = false
    @Published var isUserAtBottom = true
    @Published var selectedModel: String = "gpt-4o-mini"
    
    let availableModels = ["gpt-4o-mini", "gpt-4o", "perplexity"]
    private let userDefaultsKey = "chatMessages"
    private var currentAssistantMessageID: UUID?
    
    weak var delegate: ChatViewModelDelegate?
    
    private var urlSession: URLSession?
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        loadMessages()
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMessage = Message(text: inputText, isUser: true)
        messages.append(userMessage)
        let prompt = inputText
        inputText = ""
        streamOpenAIResponse(for: prompt)
    }
    
    private func streamOpenAIResponse(for message: String) {
        var url: URL?
        if selectedModel == "perplexity" {
            url = URL(string: "https://api.perplexity.ai/chat/completions")
        }
        else{
            url = URL(string: "https://api.openai.com/v1/chat/completions")
        }
        
        guard let url else { return }
        
        let messagesToSend: [[String: String]] = {
            let mapped = messages.map { ["role": $0.isUser ? "user" : "assistant", "content": $0.text] }
            if selectedModel == "perplexity" {
                return mapped.suffix(1)
            } else {
                return Array(mapped.suffix(10))
            }
        }()

        let body: [String: Any] = [
            "model": selectedModel == "perplexity" ? "sonar-pro" : selectedModel,
            "messages": messagesToSend,
            "temperature": 0.7,
            "stream": true
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(selectedModel == "perplexity" ? Constants.perplexityKey : Constants.openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        isTyping = true
        let assistantMessage = Message(text: "", isUser: false)
        currentAssistantMessageID = assistantMessage.id
        messages.append(assistantMessage)
        
        let task = urlSession?.dataTask(with: request)
        task?.resume()
    }
    
    // MARK: - URLSessionDelegate Methods
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let dataString = String(data: data, encoding: .utf8) else {
            print("Failed to convert data to string")
            return
        }
        let lines = dataString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .filter { $0.hasPrefix("data:") }
        
        for line in lines {
            let chunkString = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces)
            
            if chunkString == "[DONE]" { return }
            
            guard let jsonData = chunkString.data(using: .utf8) else {
                print("Failed to convert OpenAI chunk to data")
                continue
            }
            
            do {
                let deltaResponse = try JSONDecoder().decode(ChatCompletionChunk.self, from: jsonData)
                if let content = deltaResponse.choices?.first?.delta?.content {
                    DispatchQueue.main.async {
                        self.delegate?.didReceiveChunk(content)
                        self.appendChunk(content)
                    }
                }
            } catch {
                print("OpenAI decode error: \(error.localizedDescription)")
                debugPrint(chunkString)
            }
        }
    }
    
    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.isTyping = false
            if let error = error {
                print("Error receiving data: \(error.localizedDescription)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        DispatchQueue.main.async {
            self.isTyping = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func appendChunk(_ chunk: String) {
        guard let id = currentAssistantMessageID,
              let index = messages.firstIndex(where: { $0.id == id }) else { return }
        
        messages[index].text += chunk
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
