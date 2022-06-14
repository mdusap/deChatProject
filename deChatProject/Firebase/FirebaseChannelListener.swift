//
//  FirebaseChannelListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 10/6/22.
//

/// Guardar info sobre los canales en firebase y descargarlos despues desde firebase

import Foundation
import Firebase

class FirebaseChannelListener {
    
    static let shared = FirebaseChannelListener()
    
    var channelListener: ListenerRegistration!
    
    private init() { }
    
    //MARK: - Fetching
    func downloadUserChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("No hay documentos para canales")
                return
            }
            
            var allChannels = documents.compactMap { queryDocumentSnapshot -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    
    func downloadSubscribedChannels(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId).addSnapshotListener({ querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("No hay documentos para canales suscritos")
                return
            }
            
            var allChannels = documents.compactMap { queryDocumentSnapshot -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    func downloadAllChannels(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        // Accede a la coleccion creada en firebase que guarda los canales
        FirebaseReference(.Channel).getDocuments { querySnapshot, error in
            // Si no hay documentos no hara nada
            guard let documents = querySnapshot?.documents else {
                print("No hay documentos para todos los canales")
                return
            }
            // se guardan todos los canale en un array con vars de valor no nil
            var allChannels = documents.compactMap { queryDocumentSnapshot -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            // Muestra todos los canales a los que el usuario no le pertenece el id
            allChannels = self.removeSubscribedChannels(allChannels)
            // Se ordenan los canales
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        }
    }
    
    //MARK: - Añadir, Actualizar, Eliminar
    func saveCannel(_ channel: Channel) {
        
        do {
            try FirebaseReference(.Channel).document(channel.id).setData(from: channel)
            
        } catch {
            print("Error en guardar el canal ", error.localizedDescription)
        }
    }
    
    func deleteChannel(_ channel: Channel) {
        FirebaseReference(.Channel).document(channel.id).delete()
    }
    
    //MARK: - Helpers
    
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel] {
        
        var newChannels: [Channel] = []
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
    
    
    func removeChannelListener() {
        self.channelListener.remove()
    }
}
