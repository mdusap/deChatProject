//
//  FirebaseUserListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//

/// Conexion con Firebase que se encargara de los usuarios.

import Foundation
import Firebase
import ProgressHUD

class FirebaseUserListener {
    
    // Para poder acceder desde otras clases
    static let shared = FirebaseUserListener()
    // init vacio
    private init () {}
    
    //MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            // Si el email esta verificado recoger de firebase la informacion del nuevo usuario
            if error == nil && authDataResult!.user.isEmailVerified {
                
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
                
            } else {
                
                print("El email no esta verificado")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Registrar
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        // Se accede con el Auth de Firebase
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            
            // Si el error es nil
            if error == nil {
                
                authDataResult!.user.sendEmailVerification { (error) in
                    print("Error en Email Auth, descr: ", error?.localizedDescription)
                }
                
                // Si los datos de auth no es nil
                if authDataResult?.user != nil {
                    // Se crea el usuario con un estado por defecto
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hi! I´m new here!")
                    
                    // Guardado local
                    saveUserLocally(user)
                    // Guardado en Firebase
                    self.saveUserToFireStore(user)
                }
            }
        }
    }
    
    //MARK: - Reenviado de email
    // ... Para Email
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }

    // ... Para contraseña
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    // Log Out
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
        
    }
    
    //MARK: - SetUser
    func saveUserToFireStore(_ user: User) {
        
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print("Error en añadir usuario, descr:", error.localizedDescription)
        }
    }

    //MARK: - Download 
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                print("No hay documento para el usuario")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
        }
    }

    // Parte de recoger usuarios guardados en firebase
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void ) {
        // Array con los usuarios
        var users: [User] = []
        // Se accede a la coleccion creada en Firebase
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            // Si no existen datos
            guard let document = querySnapshot?.documents else {
                print("No hay documento para los usuarios")
                return
            }
            // Variable en la que se guarda el array con todos los usuarios de Firebase
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            // Foreach para recorrer todos los usuarios que tenga y añadirlos al array de users
            for user in allUsers {
                
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }

    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                
                guard let document = querySnapshot else {
                    print("No hay documento")
                    return
                }
                
                let user = try? document.data(as: User.self)

                if user != nil{
                    usersArray.append(user!)
                    count += 1
                }else{
                    ProgressHUD.showFailed("This user does not exist anymore, sorry!")
                }
                
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
    
    //MARK: - Actualizar
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print("Error en actualizar el usuario ",error.localizedDescription)
        }
    }

    
}
