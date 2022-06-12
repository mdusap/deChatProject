//
//  Status.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 1/6/22.
//

///  Modelo para los diferentes estados del usuario en la app.

import Foundation

enum Status: String, CaseIterable{
    
    case Available = "Available"
    case Busy = "Busy"
    case beBack = "Be right back"
    case notDisturb = "Do not disturb"
    case ct = "Can´t talk right now!"
    
}
