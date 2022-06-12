//
//  PhotoMS.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 8/6/22.
//

/// Esta clase se encarga de las imagenes enviadas como mensaje

import Foundation
import MessageKit

class PhotoMS: NSObject, MediaItem{
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(systemName: "photo")!
        self.size = CGSize(width: 240, height: 240)
    }
    

}
