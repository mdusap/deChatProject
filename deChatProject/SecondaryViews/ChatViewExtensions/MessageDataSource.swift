//
//  MessageDataSource.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Clase encargada de los datos de los mensajes.


import Foundation
import MessageKit
import UIKit

extension ChatViewController: MessagesDataSource{
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    //MARK: - Labels Celda Top
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Devolver texto de la parte de arriba del chat
        
        // Cada 10 mensajes mostrar tiempo
        if indexPath.section % 10 == 0 {
            let showLoadMore = (indexPath.section == 0) && (allMessages.count > displayMessagesCount)
            let text = showLoadMore ? "Swipe Down to see more..." : MessageKitDateFormatter.shared.string(from: message.sentDate)
            // Personalizar fuente y color texto
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    //Bottom Label de la Celda
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            // Ultimo mensaje
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.time() : ""
            
            return NSAttributedString(string: status, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    // Bottom Label del Mensaje
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray])
        }
        return nil
    }
}


extension ChannelChatViewController: MessagesDataSource{
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    //MARK: - Labels Celda Top
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Devolver texto de la parte de arriba del chat
        
        // Cada 10 mensajes mostrar tiempo
        if indexPath.section % 10 == 0 {
            let showLoadMore = (indexPath.section == 0) && (allMessages.count > displayMessagesCount)
            let text = showLoadMore ? "Swipe Down to see more..." : MessageKitDateFormatter.shared.string(from: message.sentDate)
            // Personalizar fuente y color texto
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    // Bottom Label del Mensaje
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sentDate.time(), attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray])
    }
}
