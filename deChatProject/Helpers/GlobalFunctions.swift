//
//  GlobalFunctions.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//

/// Funciones globales para usar en todas las clases de la app.


import Foundation
import UIKit
import AVFoundation

// Filtro añadido a ruta de archivo.
func fileNameFrom(fileUrl: String) -> String{
    
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}

// Calculo de cuanto tiempo pasa
func timePassed(_ date: Date) -> String {
    // Segundos que pasan desde la fecha actual
    let seconds = Date().timeIntervalSince(date)
    // Variable vacia en la que pondre el texto que se mostrara segun el tiempo que pase
    var e = ""
    // Si son menos de 60 segundos...
    if seconds < 60 {
        e = "Just now"
    // Si es menos de un minuto
    }else if (seconds < 60*60){
        
        // Variable para separar en minutos los segundos
        let minutes = Int(seconds / 60)
        
        // Aqui si los minutos que pasan es mayor que uno pondra mins si no pondra min
        let minText = minutes > 1 ? "mins" : "min"
        // Añade el texto de min o min y los minutos
        e = "\(minutes) \(minText)"
    // Si pasan ya mas de 60min
    }else if (seconds < 24*60*60){
        // Se divide los segundos para poner horas
        let hours = Int(seconds / (60*60))
        // Dependiendo si es una hora o mas de una hora pondra hour o hours
        let hText = hours > 1 ? "hours" : "hour"
        // Se añaden la hora y el texto
        e = "\(hours) \(hText)"
    // Si pasan dias por ejemplo pondra la fecha
    } else {
        e = date.longDate()
    }
    return e
}

// Esta funcion coge la primera imagen del video para ponerlo en el mensaje antes de darle a play
func imageVideo(video: URL) -> UIImage {
    // Creara un asset con la url del video
    let asset = AVURLAsset(url: video, options: nil)
    // Generara una imagen a partir del asset
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    // Cogera el primer frame del video
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    // La imagen sera un CGImage
    var image: CGImage?
    
    do {
        // Genera la imagen
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        
    } catch let error as NSError {
        print("Error iamgeVideo(), descr: ", error.localizedDescription)
    }
    
    // Si no hay una imagen pondra una por defecto
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage(named: "photoPlaceholder")!
    }
}
