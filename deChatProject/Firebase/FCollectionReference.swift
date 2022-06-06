//
//  FCollectionReference.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//
//  Colecciones creadas en firebase para guardar la info 
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
    case Channel
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
