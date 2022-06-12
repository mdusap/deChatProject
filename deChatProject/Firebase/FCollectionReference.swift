//
//  FCollectionReference.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//

/// Colecciones como carpetas en Firebase que guardara la info de la app según cada carpeta.

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
