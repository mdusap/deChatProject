//
//  FirebaseMessageListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Conexion con Firebase que se encargara de los mensajes que se guardaran en este

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {

    static let shared = FirebaseMessageListener()
    
    var newChatListener: ListenerRegistration!
    var updateChatListener: ListenerRegistration!
    
    private init(){}
    
    //MARK: - Ver si hay nuevos chats
    // Como lo de los chats aniguos hacer algo similar para chats nuevos
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date){
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges{
                if change.type == .added {
                    // Recoger mensajes
                    let result = Result{
                        try? change.document.data(as: Message.self)
                    }
                    
                    // Si existe guradamos en realm si no error
                    switch result {
                    case .success(let messageObject):
                        // Antes de ser guardado en realm 
                        if let message = messageObject {
                            if message.senderId != User.currentId {
                                RealmManager.shared.saveRealm(message)
                            }
                        }else{
                            print("El documento no existe")
                        }
                    case .failure(let error):
                        print("Error en decodificar el mensaje, descr: ", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    //MARK: - Ver si hay mensajes leidos
    func listenForReadChanges(_ documentId: String, collectionId: String, completion: @escaping(_ updateMessage: Message) -> Void){
        
        updateChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges{
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: Message.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        }else{
                            print("El documento no existe en el chat")
                        }
                    case .failure(let error):
                        print("Error decodificando los mensajes locales, descr: ", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    //MARK: - Ver si hay chats antiguos
    // Recoger todos los documentos con mensajes de firebase
    func checkForOldChats(_ documentId: String, collectionId: String){
        
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("No hay chats antiguos")
                return
            }
            
            // Recoger todos los chats transormarlos en Message que son los mensajes locales y guardarlos en realm
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> Message? in
                return try? queryDocumentSnapshot.data(as: Message.self)
            }
            
            //Ordenarlos por tiempo y guardar los mensajes en Realm
            oldMessages.sort(by: {$0.date < $1.date})
            for message in oldMessages {
                RealmManager.shared.saveRealm(message)
            }
        }
    }
    
    //MARK: - Añadir, eliminar actualizar desde Firebase
    func addMessage(_ message: Message, memberId: String){
        
        do {
            // Documento para cada id
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch {
            print("Error en guardar el mensaje, descr: ", error.localizedDescription)
        }
    }
    
    func addChannelMessage(_ message: Message, channel: Channel){
        
        do {
            // Documento para cada id
            let _ = try FirebaseReference(.Messages).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
        } catch {
            print("Error en guardar el mensaje, descr: ", error.localizedDescription)
        }
    }
    
    //MARK: - Actualizar estado del mensaje
    func updateMessageFB(_ message: Message, memberIds: [String]){
        
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        for userId in memberIds {
            FirebaseReference(.Messages).document(userId).collection(message .chatRoomId).document(message.id).updateData(values)
        }
    }
    
    //MARK: - Quitar lo que hace ver cada info
    func removeListener(){
        
        self.newChatListener.remove()
        
        if updateChatListener != nil {
            self.updateChatListener.remove()
        }
    }
}
