//
//  UserData.swift
//  WeChat
//
//  Created by 水哥 on 2021/2/9.
//  Copyright © 2021 Gesen. All rights reserved.
//

import Foundation
import SwiftUI

class ChatsManager: ObservableObject {
        
    static let `default` = ChatsManager()
    private var dao: ChatsDataService = ChatsDataDAO()
    @Published var chats: [Chat] = []
    
    init() {
        chats = dao.all()
    }
}

extension ChatsManager {
    
    func insert(_ chat: Chat) {
        dao.insert(chat)
        chats.insert(chat, at: 0)
    }
    
    func remove(_ chat: Chat) {
        if let index = chats.firstIndex(where: {$0.id == chat.id}) {
            remove(at: index)
        }
    }
    
    func remove(at index: Int) {
        dao.remove(chats[index].id)
        chats.remove(at: index)
    }
}
