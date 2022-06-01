//
//  FirebaseUserListener.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//
//      Esta clase se encarga de todo lo relacionado con los usuarios en firebase y en local: Login, Registrar,
//      Verificacion, Cambio de contraseña, Actualizar...
//

import Foundation
import Firebase

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
                
                print("Email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                authDataResult!.user.sendEmailVerification { (error) in
                    print("Auth email sent with error! description: ", error?.localizedDescription)
                }
                
                // Crear usuario y gaurdarlo tanto en firebase como localmente
                if authDataResult?.user != nil {
                    
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hi! I´m new here!")
                    
                    saveUserLocally(user)
                    self.saveUserToFireStore(user)
                }
            }
        }
    }
    
    //MARK: - Resend Link
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
    
    //MARK: - Save users
    func saveUserToFireStore(_ user: User) {
        
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "Adding user")
        }
    }

    //MARK: - Download User
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                print("No document for user")
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

    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void ) {
        
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            
            guard let document = querySnapshot?.documents else {
                print("No documents in all users")
                return
            }
            
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
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
                    print("No document for user")
                    return
                }
                
                let user = try? document.data(as: User.self)

                usersArray.append(user!)
                count += 1
                
                
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
    
    //MARK: - Update
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "pdating user...")
        }
    }

    
}
