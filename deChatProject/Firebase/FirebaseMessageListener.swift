//
//  FirebaseMessageListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {

    static let shared = FirebaseMessageListener()
    
    private init(){}
    
    //MARK: - Añadir, eliminar actualizar desde Firebase
    func addMessage(_ message: Message, memberId: String){
        
        do {
            // Documento para cada id
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch {
            print("Error en guardar el mensaje, descr: ", error.localizedDescription)
        }
    }
}
