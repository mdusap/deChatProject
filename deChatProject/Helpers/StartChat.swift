//
//  StartChat.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 2/6/22.
//

/// Boron StartChat, tendrá un identificador de chat único e info reciente de chats.


import Foundation
import Firebase

//MARK: - Boton StartChat
func startChat(user1: User, user2: User) -> String {
    // id unico del chat
    let chatRoomId = chatRoom(user1Id: user1.id, user2Id: user2.id)
    
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])

    return chatRoomId
    
}

//MARK: - RESTART CHAT
func restartChat(chatRoomId: String, memberIds: [String]){
    
    FirebaseUserListener.shared.downloadUsersFromFirebase(withIds: memberIds) { users in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

//MARK: - CREAR ITEMS RECIENTES
func createRecentItems(chatRoomId: String, users: [User]){
    
    // Recoge los id de todos los usuarios
    var memberIdRecent = [users.first!.id, users.last!.id]
    
    // Recoge todos los items recientes
    //print("valor", memberIdRecent)
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { s, error in
        
        // Check que usuario tiene info reciente
        guard let s = s else {return}
        
        if !s.isEmpty{
            
            memberIdRecent = removeMemberRecent(snapshoot: s, memberIds: memberIdRecent)
            //print("actualizado", memberIdRecent)
        }
        
        for userId in memberIdRecent {
            
            //print("crea reciente", memberIdRecent)
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiver(users: users)
            let receiverUser = userId == User.currentId ? getReceiver(users: users) : User.currentUser!
            let recent = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            // Añadimos la info reciente del chat a firebase
            FirebaseRecentListener.shared.saveRecent(recent)
            
        }
    }
}
//MARK: - REMOVER USER RECIENTE
func removeMemberRecent(snapshoot: QuerySnapshot, memberIds: [String]) -> [String]{
    
    var memberIdsRecent = memberIds
    
    for recentData in snapshoot.documents{
        
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID] {
            
            if memberIdsRecent.contains(currentUserId as! String) {
                
                memberIdsRecent.remove(at: memberIdsRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    return memberIdsRecent
}

//MARK: - CHAT ROOM
func chatRoom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? (user1Id + user2Id) :  (user2Id + user1Id)
    
    return chatRoomId
}

//MARK: - RECOGER RECIBIDOR
func getReceiver(users: [User]) -> User {
    
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
