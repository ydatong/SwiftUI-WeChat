//
//  ChatDataServer.swift
//  WeChat
//
//  Created by 水哥 on 2021/2/10.
//  Copyright © 2021 Gesen. All rights reserved.
//

import Foundation

/// 聊天数据存储
protocol ChatsDataService {
    
    func insert(_ chat: Chat)
    func remove(_ chat: Chat)
    func remove(_ id: ChatID)
    func update(_ chat: Chat)
    func all() -> [Chat]
}
