//
//  Message.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//
//

/// Modelo de mensaje que sera guardado en Realm, an offline data base

import Foundation
import RealmSwift

class Message: Object, Codable {
    // Codable: Convertir modelo a json para subirlo a firebase
    // Realm:   Framework para la persistencia de datos
    
    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderName = ""
    @objc dynamic var senderId = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audioUrl = ""
    @objc dynamic var videoUrl = ""
    @objc dynamic var picUrl = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var audioDuration = 0.0
    
    //Clave primaria
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
