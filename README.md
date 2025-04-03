# ChatGPT SwiftUI Demo App

## Overview
This is a simple chat application built using SwiftUI that interacts with OpenAI's GPT model to generate responses. The app allows users to send messages and receive AI-generated replies while maintaining a conversation history.

## Features
- User-friendly chat interface
- Integration with OpenAI API for AI-generated responses
- Persistent chat history using `UserDefaults`
- Message bubbles for both user and AI messages
- Auto-scrolling to the latest message

## Technology Stack
- **Swift**: Core language used for development
- **SwiftUI**: UI framework for building the chat interface
- **Combine**: Used for handling asynchronous API requests and state management
- **UserDefaults**: For local storage of chat history
- **URLSession**: For making network requests to OpenAI API

## Setup Instructions
1. Clone the repository.
2. Open the project in Xcode.
3. ⚠️ **Replace `YOUR_API_KEY` in `Constants.swift` with your OpenAI API key. This is mandatory!** ⚠️  
4. Build and run the app on a simulator or device.

## API Usage
The app sends a `POST` request to OpenAI's API with the user input and receives a response:
```swift
let body: [String: Any] = [
    "model": "gpt-4o-mini",
    "messages": [["role": "user", "content": message]],
    "temperature": 0.7
]
```
The response is parsed and displayed in the chat UI.

## License
This project is open-source and available for personal and educational use.
