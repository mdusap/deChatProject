//
//  AudioMS.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 9/6/22.
//

import Foundation
import MessageKit
import AVFoundation

class AudioMS: NSObject, AudioItem {
    
    var url: URL
    var duration: Float
    var size: CGSize
    
    init(duration: Float) {
        
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
    
    
}
