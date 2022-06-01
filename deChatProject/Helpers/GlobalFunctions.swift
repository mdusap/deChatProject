//
//  GlobalFunctions.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//
//      Esta clase se encarga de almacenar funciones globales 
//

import Foundation

func fileNameFrom(fileUrl: String) -> String{
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}
