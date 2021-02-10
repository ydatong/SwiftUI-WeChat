//
//  ChatList.swift
//  WeChat
//
//  Created by Gesen on 2020/10/16.
//  Copyright © 2020 Gesen. All rights reserved.
//

import SwiftUI

struct ChatList: View {
    
    @ObservedObject var chatsManager = ChatsManager.default
    
    let chats: [Chat]

    var body: some View {
        List {
            SearchEntry()
                .listRowInsets(EdgeInsets())
            ForEach(chats) { chat in
                ListCell(chat: chat)
            }
            .onDelete(perform: { indexSet in
                if let index = indexSet.first {
                    chatsManager.remove(chats[index])
                }
            })
            .background(Color("cell"))
        }
    }
}

struct ChatList_Previews: PreviewProvider {
    static var previews: some View {
        ChatList(chats: Chat.all)
    }
}

struct ListCell: View {
    
    let chat: Chat
    
    var body: some View {
        NavigationLink(destination: ChatView(chat: chat)) {
            ChatRow(chat: chat)
        }
    }
}
