//
//  ContentView.swift
//  Agora Sample
//
//  Created by shaun on 11/3/21.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var messenger: AgoraRTMMessenger

    var body: some View {
        if !messenger.loggedIn {
            LoginView()
        } else {
            ChatView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
