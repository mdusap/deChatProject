//
//  outgoingMessage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

// Tareas para cuando se envian mensajes
class OutgoingMessage{
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
        let currentUser = User.currentUser!
        let message = Message()
        // Parametros para el mensaje actual
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        // Dependiendo del mensaje
        if text != nil {
            // Enviamos un mensaje de texto
            sendText(message: message, text: text!, memberIds: memberIds)
        }
        
        
        // Cuando el usuario manda un mensaje se mandara una notificacion
        
        // Actualizar la info reciente del chat
    }
    
    // Guardar la info del mensaje en realm y luego en firebase
    class func sendMessage(message: Message, memberIds: [String]){
        // Guardar en realm
        RealmManager.shared.saveRealm(message)
        
        // Guardar en firebase
        for memberId in memberIds {
        
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
            //print("Guardar mensaje para: \(memberId)")
        }
    }
}

// Funcion especifica para enviar mensaje con texto
func sendText(message: Message, text: String, memberIds: [String]){
    message.message = text
    message.type = kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
}
