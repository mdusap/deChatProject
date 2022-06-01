//
//  Status.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 1/6/22.
//
//      Esta clase contendra el modelo del status que el usuario puede elegir en su status.
//


import Foundation


enum Status: String{
    
    case Available = "Available"
    case Busy = "Busy"
    case beBack = "Be right back"
    case notDisturb = "Do not disturb"
    case ct = "Can´t talk right now!"
    
    static var array: [Status]{
        var a: [Status] = []
        
        switch Status.Available {
        case .Available:
            a.append(.Available); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .beBack:
            a.append(.beBack); fallthrough
        case .notDisturb:
            a.append(.notDisturb); fallthrough
        case .ct:
            a.append(.ct);
        return a
        }
    }
    
}
