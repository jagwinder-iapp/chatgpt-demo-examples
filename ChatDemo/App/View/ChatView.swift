//
//  ChatView.swift
//  ChatDemo
//
//  Created by iapp on 02/04/25.
//

import SwiftUI

struct ChatView: View {
    
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            if viewModel.messages.isEmpty {
                emptyChatPlaceholder()
            } else {
                chatScrollView()
                    .clipped()
                    .background(Color(UIColor.secondarySystemBackground))
            }
            messageInputBar()
                .background(Color(UIColor.systemBackground))
        }
    }
    
    private func emptyChatPlaceholder() -> some View {
        VStack {
            Spacer()
            Text("No messages yet")
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
    }
    
    private func chatScrollView() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        messageBubble(for: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
            }
        }
    }
    
    private func messageBubble(for message: Message) -> some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            if !message.isUser { Spacer() }
        }
        .transition(.move(edge: message.isUser ? .trailing : .leading))
    }
    
    private func messageInputBar() -> some View {
        HStack {
            TextField("Type a message...", text: $viewModel.inputText)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button(action: viewModel.sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        if let lastMessage = viewModel.messages.last {
            if animated {
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .top)
                }
            } else {
                proxy.scrollTo(lastMessage.id, anchor: .top)
            }
        }
    }
}

