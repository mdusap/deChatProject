//
//  VideoMS.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 9/6/22.
//

/// Clase que lleva el modelo de video para recibirlo de otro usuario

import Foundation
import MessageKit

class VideoMS: NSObject, MediaItem{
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(systemName: "photo")!
        self.size = CGSize(width: 240, height: 240)
    }
    
}
