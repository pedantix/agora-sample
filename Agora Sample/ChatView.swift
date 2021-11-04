//
//  ChatView.swift
//  Agora Sample
//
//  Created by shaun on 11/4/21.
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        VStack {
            AgoraAVView()
            MessengerView()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
