//
//  MessageCellDelegate.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Clase encargada del delegado de la celda de mensaje.

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate{
    
    // Si se ha pulsado en la imagen
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        //print("Media tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
           
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil{
                //print("Imagen")
                
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                // SKPhotoBrowser para visualizar la imagen en pantalla completa, poder compartirla...
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil{
                //print("Video")
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviePlayer.player = player
                // Cuando el usuario abra un video automaticamente empezara
                self.present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    // Cuando se pulsa un mensaje
    func didTapMessage(in cell: MessageCollectionViewCell) {
    
        //print("Se ha pulsado sobre un mensaje")
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationItem != nil {
                
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                
                // Ir a la vista de mapa
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    // Cuando se pulsa el boton play de algun audio, esta funcion esta cogida del codigo de MessageKit para el play button
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Fallo en identificar el mensaje cuando se pulsa")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}


extension ChannelChatViewController: MessageCellDelegate{
    
    // Si se ha pulsado en la imagen
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        //print("Media tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
           
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil{
                //print("Imagen")
                
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                // SKPhotoBrowser para visualizar la imagen en pantalla completa, poder compartirla...
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil{
                //print("Video")
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviePlayer.player = player
                // Cuando el usuario abra un video automaticamente empezara
                self.present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    // Cuando se pulsa un mensaje
    func didTapMessage(in cell: MessageCollectionViewCell) {
    
        //print("Se ha pulsado sobre un mensaje")
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationItem != nil {
                
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                
                // Ir a la vista de mapa
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    // Cuando se pulsa el boton play de algun audio, esta funcion esta cogida del codigo de MessageKit para el play button
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Fallo en identificar el mensaje cuando se pulsa")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
