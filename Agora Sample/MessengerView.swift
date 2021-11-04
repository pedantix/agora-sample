//
//  MessengerView.swift
//  Agora Sample
//
//  Created by shaun on 11/4/21.
//

import SwiftUI

private let chatPrompt = "What's on your mind?"

struct MessengerView: View {
    @EnvironmentObject private var messenger: AgoraRTMMessenger
    @FocusState private var chatIsFocused: Bool
    @State private var newMessage = ""
    private var trimmedNewMessage: String {
        return newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack {
            messagesView
            messagSendingView
        }
    }

    @ViewBuilder
    private var messagesView: some View {
        VStack {
            Text("Chat").font(.title2)
            Spacer()
            if messenger.messages.isEmpty {
                Text("Type to chat!")
            } else {
                List {
                    ForEach(orderedMessages, id: \.self) {
                        Text($0).id($0)
                    }
                }.listStyle(.plain)
            }
        }
    }

    private var orderedMessages: [String] {
        return messenger.messages.reversed()
    }

    private var messagSendingView: some View {
        HStack {
            TextField(chatPrompt, text: $newMessage, prompt: Text(chatPrompt))
                .focused($chatIsFocused)
                .onSubmit {
                    sendMessage()
                }
                .keyboardType(.default)
                .submitLabel(.send)
                .modifier(ClearButton(text: $newMessage))
            Spacer()
            if !isSendDisabled {
                Button(action: sendMessage) {
                    Text("Send")
                }
                .disabled(isSendDisabled)
            } else {
                Button(action: dismissKeyboard) {
                    Text("Dismiss")
                }
                .disabled(!chatIsFocused)
            }
        }.padding()
    }

    private var isSendDisabled: Bool {
        return trimmedNewMessage.isEmpty
    }

    private func sendMessage() {
        guard !isSendDisabled else { return }
        messenger.sendMessage(trimmedNewMessage)
        newMessage = ""
    }

    private func dismissKeyboard() {
        chatIsFocused = false
    }
}

struct MessengerView_Previews: PreviewProvider {
    static var previews: some View {
        MessengerView().environmentObject(AgoraRTMMessenger())
    }
}

// borrowed from developer.apple.com
struct ClearButton: ViewModifier {
    @Binding var text: String

    public func body(content: Content) -> some View {
        HStack {
            content
            Button {
                self.text = ""
            } label: {
                Image(systemName: "multiply.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
}
