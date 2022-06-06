//
//  FirebaseRecentListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 2/6/22.
//
//  Lo relacionado con la info reciente de chats en Firebase.
//

import Foundation
import Firebase
import CoreMIDI

class FirebaseRecentListener {
    // Para referencia a la clase
    static let shared = FirebaseRecentListener()
    
    // Init
    private init(){}
    
    func recentChatFirestore(completion: @escaping(_ allRecents: [RecentChat]) -> Void){
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener{ (querySnapshot, error) in
            
            var recentChats: [RecentChat] = []
            
            guard let documents = querySnapshot?.documents else {
                print("No hay documentos de chats recientes")
                return
            }
            
            let allRecents = documents.compactMap { queryDocumentSnapshot -> RecentChat? in
                // decodificar chats desde firebase
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            // Check si el ultimo mensaje esta vacio o no 
            for recent in allRecents {
                if recent.lastMessage != "" {
                    // Añadimos info reciente al chat reciente xd
                    recentChats.append(recent)
                }
            }
            
            // Ordena los chats
            recentChats.sort(by: {$0.date! > $1.date!  })
            completion(recentChats)
            
        }
    }
    
    func resetRecentCounter(chatRoomId: String){
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("No hay documentos con info reciente")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
                
            }
            
            if allRecents.count > 0{
                self.clearCounter(recent: allRecents.first!)
            }
            
           
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
    
    
    // Cuando se pulse en un chat quitar el simbolo de mostrar mensaje sin leer
    func clearCounter(recent: RecentChat){
        var nRecent = recent
        nRecent.unreadCounter = 0
        self.saveRecent(nRecent)
    }
    
    
    // Añadir info reciente a firebase
    func saveRecent(_ recent: RecentChat){
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch{
            print("Error en guardar info reciente del chat: ", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentChat){
        FirebaseReference(.Recent).document(recent.id).delete()
        
    }
}
