//
//  MKMessage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//
//  Modelo del mensaje
//

import Foundation
import MessageKit
import CoreLocation

// Requerimientos para un objeto mensaje
class MKMessage: NSObject, MessageType{
    
    var messageId: String = ""
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
    
    var status: String
    var readDate: Date
    
    //Constructor, conexion con lo que hay en comun en esta clase y la de Message
    init(message: Message) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        // Switch segun tipo de mensaje
//        switch message.type {
//        case <#pattern#>:
//            <#code#>
//        default:
//            <#code#>
//        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        // Si el mensaje no corresponde con el id del usuario current sera un sender y sera un mensaje outgoing
        self.incoming = User.currentId != mkSender.senderId
        
    }
}
