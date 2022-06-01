//
//  User.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//
//      Esta clase guarda el modelo de usuario asi como otras funciones con respecto al usuario, como almacenarlo
//      de manera local y creacion de usuarios de ejemplo
//

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
    
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding User from UserDefaults, description: ", error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}



func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("Error saving user locally, description: ", error.localizedDescription)
    }
}


func createDummyUsers() {
    print("Dummy users just for example....")
    
    let names = ["Micio", "Oreo", "Emilia", "Oscar"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5 {
        
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
