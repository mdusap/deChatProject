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

func playVideo(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        
    } catch let error as NSError {
        print("error making thumbnail ", error.localizedDescription)
    }
    
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage(named: "photoPlaceholder")!
    }
}
