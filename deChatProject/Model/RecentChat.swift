//
//  RecentChat.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 2/6/22.
//
//      Estructura de un chat reciente para mostrar en la celda, en la tabla de chats.
//

import Foundation
import FirebaseFirestoreSwift


struct RecentChat: Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
}
