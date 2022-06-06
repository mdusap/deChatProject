//
//  InputBarViewDelegate.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//
//  Clase para recoger la info en el momento que el usuario introduce algo en el text field
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        // Ver cuando el texto esta cambiando
        if text != "" {
            //print("Escribiendo...")
        }
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Ver si ya hay algo en el text area
        for component in inputBar.inputTextView.components {
            // Si el usuario manda un mensaje los demas parametros los pondremos a nil y asi con cada uno 
            if let text = component as? String{
                //print("Mensaje enviado con texto: ",text)
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
