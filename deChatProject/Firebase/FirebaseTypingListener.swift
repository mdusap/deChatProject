//
//  FirebaseTypingListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 7/6/22.
//

/// Conexion con Firebase que se encarga de ver si el usuario esta escribiendo o no, esta info tendra un chatId de cada chat y aparecera en Firebase para tener constancia de esos datos, para falso si no esta escribiendo y verdadero si lo esta, esa info se recoge para luego mostrarla en el label del chat.

import Foundation
import Firebase

class FirebaseTypingListener {
    // Desde donde pdremos acceder a cada funcion de esta clase
    static let shared = FirebaseTypingListener()
    var typingListener: ListenerRegistration!
    
    // Esta funcion estara atenta a cada cambio acerca del "Escribiendo..."
    func createTypingObserver(chatRoomId: String, completion: @escaping(_ isTyping: Bool) -> Void) {
        // Crear un nuevo documento en firebase para guardar los datos del typing
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data()! {
                    
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    //MARK: - Guarda un contador del Escribiendo
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        
        FirebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])
    }
    
    //MARK: - Quita la funcion de registrar el Escribiendo
    func removeTypingListener() {
        self.typingListener.remove()
    }
    
}
