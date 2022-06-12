//
//  outgoingMessage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

/// Mensajes salientes.

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

// Tareas para cuando se envian mensajes
class OutgoingMessage{
    
    //MARK: - Enviar Mensaje
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
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
        
        if photo != nil {
            sendPhoto(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideo(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            //print("Ubicacion enviada", LocationManager.shared.currentLocation)
            sendLoc(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
            //print("Audio enviado ", audio, audioDuration)
            sendAudio(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
    }
    
    class func sendChannel(channel: Channel, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?) {
        
        
        let currentUser = User.currentUser!
        var channel = channel
        
        let message = Message()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        // Dependiendo del mensaje
        if text != nil {
            // Enviamos un mensaje de texto
            sendText(message: message, text: text!, memberIds: channel.memberIds, channel: channel)
        }
        
        if photo != nil {
            sendPhoto(message: message, photo: photo!, memberIds: channel.memberIds, channel: channel)
        }
        
        if video != nil {
            sendVideo(message: message, video: video!, memberIds: channel.memberIds, channel: channel)
        }
        
        if location != nil {
            //print("Ubicacion enviada", LocationManager.shared.currentLocation)
            sendLoc(message: message, memberIds: channel.memberIds, channel: channel)
        }
        
        if audio != nil {
            //print("Audio enviado ", audio, audioDuration)
            sendAudio(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: channel.memberIds, channel: channel)
        }
        
//        PushNotificationService.shared.sendPushNotificationTo(userIds: removeCurrentUserFrom(userIds: channel.memberIds), body: message.message, channel: channel, chatRoomId: channel.id)
        
        channel.lastMessageDate = Date()
        FirebaseChannelListener.shared.saveCannel(channel)
      
    }
    
    //MARK: - Guardar Mensaje
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
    
    // Guarda mensaje de un canal
    class func sendChannelMessage(message: Message, channel: Channel){

        RealmManager.shared.saveRealm(message)
        FirebaseMessageListener.shared.addChannelMessage(message, channel: channel)
     
    }
}
//MARK: - Tipo mensaje
// Funcion especifica para enviar mensaje con texto
func sendText(message: Message, text: String, memberIds: [String], channel: Channel? = nil){
    
    message.message = text
    message.type = kTEXT
    
    if channel != nil {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
    }else{
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}

// Funcion especifica para enviar una imagen
func sendPhoto(message: Message, photo: UIImage, memberIds: [String], channel: Channel? = nil){
    
    //print("Imagen enviada")
    
    message.message = "Image"
    message.type = kPHOTO
    
    let filename = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)" + "\(filename)" + ".jpg"
    
    // Guardamos de manera local con la funcion que hemos creado en FileStorage para eso
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: filename)
    
    // Guardamos imagenes en una carpeta en Firebase Storage
    FileStorage.uploadImage(photo, directory: fileDirectory) { imageURL in
        
        if imageURL != nil {
            
            message.picUrl = imageURL!
           
            if channel != nil {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            }else{
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}

// Funcion para enviar un video
func sendVideo(message: Message, video:Video, memberIds:[String], channel: Channel? = nil){
    //print("Video enviado")
    
    // El mensaje que se vera y el tipo del mensaje
    message.message = "Video"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    
    // Se guarda la imagen que se ve antes de darle al play y el video en si en Firebase
    let playImageDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    // Convertir el video en datos
    let editor = VideoEditor()
    
    editor.process(video: video) { precessedVideo, videoUrl in
        
        if let tempPath = videoUrl{
            // Cogera la primera imagen del video que se podra pulsar con el dedo para ver el contenido 
            let play = playVideo(video: tempPath)
            
            FileStorage.saveFileLocally(fileData: play.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            FileStorage.uploadImage(play, directory: playImageDirectory) { imageLink in
                
                if imageLink != nil{
                    // Convertira lo que tengamos en tempPath como datos
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { videoLink in
                        
                        message.picUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        // Enviar el mensaje
                        if channel != nil {
                            OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
                        }else{
                            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
                        }
                    }
                }
            }
        }
    }
}

func sendLoc(message: Message, memberIds:[String], channel: Channel? = nil){
    
    // Acceder al mensaje y a la ubicacion actual
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    if channel != nil {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
    }else{
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}


func sendAudio(message: Message, audioFileName: String, audioDuration: Float, memberIds:[String], channel: Channel? = nil){
    
    message.message = "Audio"
    message.type = kAUDIO
    
    let fileDirectory =  "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
    
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { audioUrl in
        
        if audioUrl != nil {
            
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
           
            if channel != nil {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            }else{
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}

