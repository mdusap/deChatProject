//
//  MessageDef.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// MessageKit implementacion 

import Foundation
import UIKit
import MessageKit

// Struct con el id del usuario que envia un mensaje y el nombre que se mostrara
struct MKSender: SenderType, Equatable{
    var senderId: String
    var displayName: String
}

// Bubble mensaje colores personalizads
enum MessageDefaults {
    // Si el mensaje se envia estara de este color
    static let bubbleColorOutgoing = UIColor(named: "chatOutgoingBubble") ?? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    // Si el mensaje es recibido se muestra de este color
    static let bubbleColorIncoming = UIColor(named: "chatIncomingBubble") ?? UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}
