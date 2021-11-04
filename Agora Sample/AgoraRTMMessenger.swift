//
//  AgoraRTMMessenger.swift
//  Agora Sample
//
//  Created by shaun on 11/4/21.
//

import Foundation
import AgoraRtmKit
import Combine

class AgoraRTMMessenger: NSObject, ObservableObject {
    private lazy var agoraRTMKit: AgoraRtmKit = {
        guard let kit = AgoraRtmKit(appId: AgoraConfig.sampleAppID, delegate: self) else {
            fatalError("AgoraRtmKit failed to load")
        }
        return kit
    }()

    @Published var loggedIn = false
    @Published var lastLoginError: String?
    @Published var messages = [String]()

    let updatePublisher = PassthroughSubject<Void, Never>()

    private var channel: AgoraRtmChannel?
    private var username = "none"

    private func addMessage(for user: String, text: String) {
        DispatchQueue.main.async {
            self.messages.append("\(user): \(text)")
            self.updatePublisher.send()
        }
    }
}

// MARK: - Public  API
extension AgoraRTMMessenger {
    func login(as username: String) {
        agoraRTMKit.login(byToken: AgoraConfig.sampleAppIDRTM,
                          user: username) { [unowned self] agoraRtmLoginErrorCode in
            if agoraRtmLoginErrorCode == .ok {
                self.loggedIn = true
                self.channel = agoraRTMKit.createChannel(withId: AgoraConfig.testingChannel, delegate: self)
                self.channel?.join(completion: { err in
                    if err == .channelErrorOk {
                        self.username = username
                        addMessage(for: username, text: "Joined")
                        return print("Joined channel ok as \(username)")
                    }
                    print("Error code \(err.rawValue) joining channel")
                })
                return print("Logged in successffully")
            }
            lastLoginError = "Error logging in for \(username) code: \(agoraRtmLoginErrorCode.rawValue)"
            print(lastLoginError ?? "")
        }

    }

    func sendMessage(_ text: String) {
        channel?.send(.init(text: text)) { [unowned self] agoraRtmSendChannelMessageErrorCode in
            if agoraRtmSendChannelMessageErrorCode == .errorOk {
                addMessage(for: username, text: text)
                return print("Sent message to channel -> \(text)")
            }
            print("Error sending message code: \(agoraRtmSendChannelMessageErrorCode.rawValue)")
        }
    }
}

// MARK: - AgoraRtmChannelDelegate
extension AgoraRTMMessenger: AgoraRtmChannelDelegate {
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        print("Received \(message) from \(member)")
        addMessage(for: member.userId, text: message.text)
    }

    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        print("Member joined \(member.userId)")
        addMessage(for: member.userId, text: "Joined")
    }
}

// MARK: - AgoraRtmDelegate
extension AgoraRTMMessenger: AgoraRtmDelegate { }
