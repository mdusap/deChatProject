//
//  Constants.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//

/// Constantes e UserDefaults, en este caso UserDefaults sera usado para guardar alguna info relevante en el directorio del proyecto.

import Foundation

let userDefaults = UserDefaults.standard

// Key para donde se guarda la ruta en donde se guardaran los archivos para cada objeto
public let kFILEREFERENCE = "gs://dechatproject-873a1.appspot.com"

// Numero de mensajes
public let kNUMBERMESSAGES = 12

// Estado
public let kSTATUS = "status"

// Usuario corriente
public let kCURRENTUSER = "currentUser"

// Para cuando el usuario entra por primera vez
public let kFIRSTRUN = "firstRun"

// Identificador del chat room
public let kCHATROOMID = "chatRoomId"

// Identificador del usuario que envia un mensaje
public let kSENDERID = "senderId"

// Para mostrar en el mensaje enviado o leido
public let kSENT = "Sent"
public let kREAD = "Read"

// Dependiendo de lo que el usuario envie en el chat
public let kTEXT = "text"
public let kPHOTO = "photo"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"

// Tiempo
public let kDATE = "date"
public let kREADDATE = "date"

// Para los canales
public let kADMINID = "adminId"
public let kMEMBERIDS = "memberIds"
