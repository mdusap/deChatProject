//
//  MessageDef.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable{
    var senderId: String
    var displayName: String
}

// Bubble mensaje colores
enum MessageDefaults {
    static let bubbleColorOutgoing = UIColor(named: "chatOutgoingBubble") ?? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static let bubbleColorIncoming = UIColor(named: "chatIncomingBubble") ?? UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}
