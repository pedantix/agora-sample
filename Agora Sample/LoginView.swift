//
//  LoginView.swift
//  Agora Sample
//
//  Created by shaun on 11/4/21.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var messenger: AgoraRTMMessenger
    @State private var username = ""
    @FocusState private var usernameIsFocused: Bool

    var body: some View {
        ZStack {
            loginForm
            if messenger.isLoggingIn {
                ProgressView()
            }
        }
    }

    private var loginForm: some View {
        VStack {
            Spacer()
            VStack {
            TextField("Username", text: $username, prompt: Text("Enter in your username to chat"))
                .focused($usernameIsFocused)
            }
            .padding(.leading, 34)
            .onSubmit {
                logon()
            }
            .keyboardType(.namePhonePad)
            .textContentType(.username)
            .submitLabel(.go)

            Spacer()
            Button {
                self.logon()
            } label: {
                Text("Log on")
                    .foregroundColor(buttonTextColor)
            }.disabled(self.isLogonDisabled)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(.blue)
        }
        .task {
            // Do this to grab the focus after the screen has been loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                usernameIsFocused = true
            }
        }
    }

    private var buttonTextColor: Color {
        return isLogonDisabled ? .gray : .white
    }

    private var isLogonDisabled: Bool {
        return username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func logon() {
        guard !isLogonDisabled else { return}
        messenger.login(as: username)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
