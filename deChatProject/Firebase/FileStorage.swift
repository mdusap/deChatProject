//
//  FileStorage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//
//  Lo relacionado con Storage de firebase: imagenes
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage{
    
    //MARK: - Subir una imagen a Firebase Storage
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void){
        // Base link para el archivo añadido al directorio
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        //  Convertir la imagen a data
        let imageData = image.jpegData(compressionQuality: 0.6)
        // Hay que hacer un task para poder subirlo al storages
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error en guardar la imagen, descr: \(error?.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { snapshot in
            // Porcentage del progreso de la subida
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    //MARK: - Descargar la imagen desde Firebase para usarla en la app
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            // Recogerlo de manera local
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)){
                
                completion(contentsOfFile)
                
            }else{
                print("No se ha podido convertir la imagen")
                completion(UIImage(named: "Avatar"))
            }
            
        }else{
            // Download de firebase
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDowloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        
                        // Guardar las imagenes de manera local 
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    }else{
                        print("No hay documento")
                        DispatchQueue.main.async{
                            completion(nil)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    //MARK: - Subir el video
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void){
        
        // Base link para el archivo añadido al directorio
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)

        // Hay que hacer un task para poder subirlo al storages
        var task: StorageUploadTask!
        task = storageRef.putData(video as Data, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error en guardar el video, descr: \(error?.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        // Indicador de loading
        task.observe(StorageTaskStatus.progress) { snapshot in
            // Porcentage del progreso de la subida
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    //MARK: - Descargar el video
    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if fileExistsAtPath(path: videoFileName) {

            completion(true, videoFileName)
            
        }else{
            // Download de firebase
            if videoLink != "" {
                
                let downloadQueue = DispatchQueue(label: "VideoDowloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: videoUrl!)
                    
                    if data != nil {
                        
                        // Guardar las imagenes de manera local
                        FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                        
                        DispatchQueue.main.async {
                            completion(true, videoFileName)
                        }
                        
                    }else{
                        print("No hay documento")
                    }
                }
            }
        }
    }
    
    //MARK: - Audio
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void){
        
        let fileName = audioFileName + ".m4a"
        
        // Base link para el archivo añadido al directorio
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)

        // Hay que hacer un task para poder subirlo al storages
        var task: StorageUploadTask!
        
        // Comprobar si los datos ya estan guardados de manera local
        if fileExistsAtPath(path: fileName) {
            
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)){
                
                // Lo que guardaremos en firebase ya esta guardado de manera local hay que coger eso para guardar en firebase
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { metadata, error in
                    
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("Error en guardar el audio, descr: \(error?.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        
                        guard let downloadUrl = url else {
                            completion(nil)
                            return
                        }
                        
                        completion(downloadUrl.absoluteString)
                    }
                })
                
                // Indicador de loading
                task.observe(StorageTaskStatus.progress) { snapshot in
                    // Porcentage del progreso de la subida
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            } else {
                print("No hay ningun audio para subir!")
            }
        }
    }
    
    //MARK: - Descargar el audio
    class func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
        
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        
        if fileExistsAtPath(path: audioFileName) {

            completion(audioFileName)
            
        }else{
            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            
            downloadQueue.async {
                
                let data = NSData(contentsOf: URL(string: audioLink)!)
                
                if data != nil {
                    
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                    
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                    
                } else {
                    print("No hay grabaciones en la base de datos")
                }
            }
        }
    }
    
    //MARK: - Guardar de manera local
    
    class func saveFileLocally(fileData: NSData, fileName: String){
        
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        // Means whenever thers a file in directory its override it 
        fileData.write(to: docUrl, atomically: true)
    }
}


//Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
