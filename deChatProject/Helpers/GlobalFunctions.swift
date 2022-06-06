//
//  GlobalFunctions.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//
//      Funciones globales para usar en todas las clases de la app.
//

import Foundation

// Filtro añadido a ruta de archivo.
func fileNameFrom(fileUrl: String) -> String{
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}

// Calculo de cuanto tiempo pasa
func timePassed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    
    var e = ""
    
    if seconds < 60 {
        e = "Just now"
    }else if (seconds < 60*60){
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins" : "min"
        
        e = "\(minutes) \(minText)"
    }else if (seconds < 24*60*60){
        let hours = Int(seconds / (60*60))
        let hText = hours > 1 ? "hours" : "hour"
        
        e = "\(hours) \(hText)"
    } else {
        e = date.longDate()
    }
    
    return e
}
