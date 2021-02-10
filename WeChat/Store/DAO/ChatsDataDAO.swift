//
//  ChatsDataDAO.swift
//  WeChat
//
//  Created by 水哥 on 2021/2/10.
//  Copyright © 2021 Gesen. All rights reserved.
//

import Foundation
import SQLite

class ChatsDataDAO : ChatsDataService {
    
    struct ChatTable {
        static let chat = Table("chat")
        static let member = Table("member")
    }
    
    struct ChatField {
        static let id = Expression<UUID>("id")
        static let desc = Expression<String>("desc")
        static let senderId = Expression<UUID>("senderId")
        static let time = Expression<String>("time")
    }
    
    struct MemeberField {
        static let id = Expression<UUID>("id")
        static let background = Expression<String?>("background")
        static let icon = Expression<String>("icon")
        static let identifier = Expression<String?>("identifier")
        static let name = Expression<String>("name")
    }
    
    private lazy var db: Connection? = {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        return try? Connection("\(path)/wechat.sqlite3")
    }()
    
    init() {
        try? createTable()
    }
    
    //建表
    private func createTable() throws {
        
        try db?.run(ChatTable.chat.create(temporary: false, ifNotExists: true) { (t) in
            t.column(ChatField.id,primaryKey: true)
            t.column(ChatField.desc)
            t.column(ChatField.senderId)
            t.column(ChatField.time)
        })
        
        try db?.run(ChatTable.member.create { (t) in
            t.column(MemeberField.id,primaryKey: true)
            t.column(MemeberField.background)
            t.column(MemeberField.icon)
            t.column(MemeberField.identifier)
            t.column(MemeberField.name)
        })
    }
    
}

extension ChatsDataDAO {
    
    func insert(_ chat: Chat) {
        try? db?.transaction {
            self.insertChat(chat)
            self.memberExsits(chat.sender.id) ?
                self.updateMember(chat.sender) :
                self.insertMember(chat.sender)
        }
    }
    
    func remove(_ chat: Chat) {
        remove(chat.id)
    }
    
    func remove(_ id: ChatID) {
        _ = try? db?.run(ChatTable.chat.filter(id == ChatField.id).delete())
    }
    
    func update(_ chat: Chat) {
        
    }
    
    func all() -> [Chat] {
        var result: [Chat] = []
        guard let chats = try? db?.prepare(ChatTable.chat) else { return result }
        for chat in chats {
            if let memberRow = member(chat[ChatField.senderId]) {
                result.append(mapChat(chat, memberRow: memberRow))
            }
        }
        return result
    }
}

extension ChatsDataDAO {
    
    private func insertChat(_ chat: Chat) {
        _ = try? db?.run(ChatTable.chat.insert(
            ChatField.id <- chat.id,
            ChatField.desc <- chat.desc,
            ChatField.senderId <- chat.sender.id,
            ChatField.time <- chat.time
        ))
    }
    
    private func insertMember(_ member: Member) {
        _ = try? db?.run(ChatTable.member.insert(
            MemeberField.id <- member.id,
            MemeberField.background <- member.background,
            MemeberField.identifier <- member.identifier,
            MemeberField.icon <- member.icon,
            MemeberField.name <- member.name
        ))
    }
    
    private func updateMember(_ member: Member) {
        _ = try? db?.run(ChatTable.member.update(
            MemeberField.background <- member.background,
            MemeberField.identifier <- member.identifier,
            MemeberField.icon <- member.icon,
            MemeberField.name <- member.name
        ))
    }
    
    private func memberExsits(_ id: UUID) -> Bool {
        return member(id) != nil
    }
    
    private func member(_ id: UUID) -> Row? {
        let query = ChatTable.member.filter(id == MemeberField.id)
        guard let result = try? db?.prepare(query) else { return nil }
        for row in result {
            return row
        }
        return nil
    }
    
    private func mapChat(_ chatRow: Row, memberRow: Row) -> Chat {
        Chat(id: chatRow[ChatField.id],
             desc: chatRow[ChatField.desc],
             sender:mapMember(memberRow),
             time: chatRow[ChatField.time])
    }
    
    private func mapMember(_ row: Row) -> Member {
        Member(id: row[MemeberField.id],
               background: row[MemeberField.background],
               icon: row[MemeberField.icon],
               identifier: row[MemeberField.identifier],
               name: row[MemeberField.name])
    }
}

extension UUID : Value {
    
    public static let declaredDatatype = "UUID"

    public static func fromDatatypeValue(_ datatypeValue: String) -> UUID {
        return UUID(uuidString: datatypeValue)!
    }

    public var datatypeValue: String {
        return self.uuidString
    }
}
