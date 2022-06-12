//
//  MKMessage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Modelo MessageKitMessage del mensaje


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
    
    var photoItem: PhotoMS?
    var videoItem: VideoMS?
    var locationItem: LocationMS?
    var audioItem: AudioMS?
    
    var status: String
    var readDate: Date
    
    //Constructor, conexion con lo que hay en comun en esta clase y la de Message
    init(message: Message) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        // Switch segun tipo de mensaje
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem = PhotoMS(path: message.picUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        case kVIDEO:
            let videoItem = VideoMS(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
        case kLOCATION:
            let locationItem = LocationMS(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
        case kAUDIO:
            let audioItem = AudioMS(duration: 2.0)
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
        default:
            self.kind = MessageKind.text(message.message)
            print("Tipo de mensaje desconocido")
        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        // Si el mensaje no corresponde con el id del usuario current sera un sender y sera un mensaje outgoing
        self.incoming = User.currentId != mkSender.senderId
        
    }
}
