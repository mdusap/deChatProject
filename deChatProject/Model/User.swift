//
//  User.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//

///  Modelo para Usuario con sus atributos, funcion para decodificar json y guardat datos en local,
///  y usuarios de prueba.


import Foundation
import Firebase
import FirebaseFirestoreSwift


struct User: Codable, Equatable {
    
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    //MARK: - ID DEL USUARIO ACTUAL
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    //MARK: - DATOS USUARIO ACTUAL
    static var currentUser: User? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error en decodificar usuario desde UserDefaults, descr: ", error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

//MARK: - GUARDAR USUARIO LOCALMENTE
func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("Error en guardar el usuario de manera local, descr: ", error.localizedDescription)
    }
}

//MARK: - USUARIOS PREDEFINIDOS
func preUsers() {
    print("Usuarios de ejemplo")
    
    let names = ["Micio", "Oreo", "Emilia", "Oscar"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<4 {
        
        let id = UUID().uuidString
        
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpd"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = User(id: id, username: names[i], email: "user\(userIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No Status")
            
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFireStore(user)
        }
        
        imageIndex += 1
        if imageIndex == 5 {
            imageIndex = 1
        }
    }
}
