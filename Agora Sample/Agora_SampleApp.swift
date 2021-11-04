//
//  Agora_SampleApp.swift
//  Agora Sample
//
//  Created by shaun on 11/3/21.
//

import SwiftUI

@main
// swiftlint:disable:next type_name
struct Agora_SampleApp: App {
    @StateObject var messenger = AgoraRTMMessenger()

    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(messenger)
        }
    }
}
