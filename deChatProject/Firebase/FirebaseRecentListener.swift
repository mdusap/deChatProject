//
//  FirebaseRecentListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 2/6/22.
//

/// Conexion con Firebase que se encargara de la información reciente.

import Foundation
import Firebase
import CoreMIDI

class FirebaseRecentListener {
    // Para referencia a la clase
    static let shared = FirebaseRecentListener()
    
    // Init
    private init(){}
    
    //MARK: - Chats recientes
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
    
    //MARK: - Contador info reciente
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
    
    //MARK: - Actualizar infos recientes
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
                self.updateRecentNew(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    //MARK: - Actualizar reciente como mensaje
    
    // Buscara info reciente que perteneces a un chat room especifico
    private func updateRecentNew(recent: RecentChat, lastMessage: String){
        
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
    
    //MARK: - Limpiar contador
    // Cuando se pulse en un chat quitar el simbolo de mostrar mensaje sin leer
    func clearCounter(recent: RecentChat){
        var nRecent = recent
        nRecent.unreadCounter = 0
        self.saveRecent(nRecent)
    }
    
    //MARK: - Guardar reciente
    // Añadir info reciente a firebase
    func saveRecent(_ recent: RecentChat){
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch{
            print("Error en guardar info reciente del chat: ", error.localizedDescription)
        }
    }
    
    //MARK: - Eliminar reciente
    func deleteRecent(_ recent: RecentChat){
        FirebaseReference(.Recent).document(recent.id).delete()
    }
}
