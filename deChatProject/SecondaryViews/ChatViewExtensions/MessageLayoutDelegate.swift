//
//  MessageLayoutDelegate.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Clase encargada para mostrar por ejemplo en el chat antes de entrar ultimo mensaje, y cuantos hay por ver y del mensaje dentro del chat.

import Foundation
import MessageKit

extension ChatViewController: MessagesLayoutDelegate{
    //MARK: - Top Label Celda
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section % 10 == 0 {
            if ((indexPath.section == 0) && (allMessages.count > displayMessagesCount)) {
                return 40
            }
            return 18
        }
        
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
        
    }
    
    //MARK: - Bottom Label Mensaje
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}

extension ChannelChatViewController: MessagesLayoutDelegate {

    //MARK: - Cell top label
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        if indexPath.section % 3 == 0 {

            if ((indexPath.section == 0) && (allMessages.count > displayMessagesCount)) {

                return 40
            }
            return 18
        }

        return 0
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }


    //MARK: - Message Bottom Label
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 10
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }

}
