//
//  Extensions.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//

/// Formato personalizado para imagenes y fechas usadas a lo largo de la app, si, encontrado en internet.


import UIKit


extension UIImage {
    
    // Dependiendo de la posición del movil se vera de una manera u otra
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    // Para cuando se corte la imagen y quede bonto saber que parte e la mas pequeña
    var breadth: CGFloat { return min(size.width, size.height) }
    // Coge el minimo de breadth y crea el cuadrado de la imagen
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    // Este crea un rectangulo para volver a dibujar la imagen y quede correctamente
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    // Variable para que la imagen se ponga circular y con zoom.
    var circleMasked: UIImage? {
        
        // Crea un contexto gráfico basado en mapas de bits con las opciones especificadas.
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        // Defer es para cuando se necesite algo hecho sin importar otra cosa, esta funcion gara eso si o si
        defer { UIGraphicsEndImageContext() }
        
        // CGImage para poder implementar los cambios de medidas, cortara la imagen en un tamaño especifico con CGRect que es, una estructura que contiene un punto en un sistema de coordenadas bidimensional, cortara segun landscape y portrait
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        
        // Es una ruta que consta de segmentos de línea recta y curva que puede representar en los views.
        UIBezierPath(ovalIn: breadthRect).addClip()
        // Esto crea la nueva imagen que la dibujara en el rectangulo
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        // Esto devolvera el resultado
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

extension Date {
    
    // Fecha
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    // Fecha y hora
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }
    
    // Hora
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    // Los segundos que pasan entre dos tiempos
    func interval(ofComponent comp: Calendar.Component, from date: Date) -> Float {
        
        let currentCalendar = Calendar.current
        
        guard  let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard  let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return Float(start - end)
    }

}
