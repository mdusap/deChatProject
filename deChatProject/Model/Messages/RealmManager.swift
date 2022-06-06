//
//  RealmManager.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//
//  Manager del framework RealmSwift
//

import Foundation
import RealmSwift

class RealmManager {
    // Para poder llamar a la clase en otras partes del proyecto
    static let shared = RealmManager()
    let realm = try! Realm()
    
    // Singleton
    private init(){}
    
    // Guardar objetos en Realm, cualquier objeto, mientras cumpla con el protocolo de objeto
    func saveRealm<T: Object>(_ object: T){
        
        do {
            try? realm.write{
                realm.add(object, update: .all)
            }
        } catch {
            print("Error al guardar en realm, descr: ", error.localizedDescription)
        }
    }
    
    
}
