# ChatGPT SwiftUI Demo App

## Overview
A sleek SwiftUI-based chat application that leverages OpenAI's GPT and Perplexity AI models to generate intelligent responses. It supports real-time streaming replies and retains conversation history for a seamless user experience.

## Features
- ✨ Real-time streaming responses (token-by-token)
- 🧠 Supports multiple models: `gpt-4o-mini`, `gpt-4o`, and `perplexity`
- 💬 Clean and intuitive chat UI with message bubbles
- 💾 Persistent chat history using `UserDefaults`
- ⬇️ Auto-scrolls to latest message
- 🔄 Model switcher for dynamic API usage

## Technology Stack
- **Swift** – Core programming language
- **SwiftUI** – Declarative UI framework
- **Combine** – State management & reactive updates
- **UserDefaults** – Simple local storage
- **URLSession** – Streamed HTTP requests to APIs

## Setup Instructions
1. Clone the repository.
2. Open the project in Xcode.
3. ⚠️ **Update `Constants.swift` with your API keys**:
   - Replace `YOUR_API_KEY` with your OpenAI key.
   - Replace `YOUR_PERPLEXITY_KEY` with your Perplexity API key.
4. Build and run the app on a device or simulator.

## API Usage
The app sends a streamed `POST` request to either OpenAI or Perplexity API, depending on the selected model:

```swift
let body: [String: Any] = [
    "model": selectedModel == "perplexity" ? "sonar-pro" : selectedModel,
    "messages": recentMessages,
    "temperature": 0.7,
    "stream": true
]
```

### Supported Models
- `gpt-4o-mini` (default)
- `gpt-4o`
- `perplexity` (uses `sonar-pro` under the hood)

### Streaming
Streaming responses are handled chunk-by-chunk using `URLSessionDataDelegate`, making the AI feel more responsive and dynamic.

## License
Open-source and available for personal or educational use. Contributions welcome!
