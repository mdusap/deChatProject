//
//  IncomingMessage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Mensajes entrantes

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
        if message.type == kPHOTO {
            
            let photoItem = PhotoMS(path: message.picUrl)
            // Actualizar
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: message.picUrl) { image in
                
                mkMessage.photoItem?.image = image
                // Refrescar
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        // Si el tipo de mensaje es un video cargara la imagen principal antes de darle a play y el video
        if message.type == kVIDEO{
            
            FileStorage.downloadImage(imageUrl: message.picUrl) { play in
                
                FileStorage.downloadVideo(videoLink: message.videoUrl) { isReadyToPlay, videoFileName in
                    
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: videoFileName))
                    let videoItem  = VideoMS(url: videoURL)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = play
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        // Si el tipo de mensaje en una una ubicacion
        if message.type == kLOCATION {
            
            let locationItem = LocationMS(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        // Si el mensaje es un audio
        if message.type == kAUDIO {
            
            let audioMessage = AudioMS(duration: Float(message.audioDuration))
            
            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)
            
            FileStorage.downloadAudio(audioLink: message.audioUrl) { fileName in
                
                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                
                mkMessage.audioItem?.url = audioURL
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }
}
