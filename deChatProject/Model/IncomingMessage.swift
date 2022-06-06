//
//  IncomingMessage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage{
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    //MARK: - Crear Mensaje
    func createMessage(message: Message) -> MKMessage?{
        
        let mkMessage = MKMessage(message: message)
        // Mensajes multimedia
        
        return mkMessage
    }
}
