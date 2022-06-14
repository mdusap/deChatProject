//
//  InputBarViewDelegate.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 6/6/22.
//

///  Clase para recoger la info en el momento que el usuario introduce algo en el text field


import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        // Si en el text fiel el texto no esta vacio el usuario esta escribiendo
        if text != "" {
            //print("Escribiendo...")
            typingIndicatorUpdate()
        } // No pongo else que en la otra funcion ya para despues de un segundo si no esta escribiendo.
        // Actualizar boton para enviar audio, si no hay texto mostrar send si no hay text mostrar microfono
        updateMicButton(show: text == "")
        
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


extension ChannelChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        updateMicButton(show: text == "")
        
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

