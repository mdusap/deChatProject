//
//  FileStorage.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//
//  This class is to save image that user upload as photo avat
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage{
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void){
        // Base link to folder added to directory
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        // Convert image to data, 1 to maximum quality and 0 to minimum
        let imageData = image.jpegData(compressionQuality: 0.6)
        // Need a task in order to save it to firebase
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error uploading image!: \(error?.localizedDescription)")
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
            // Percentage of the progress
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            // Get it locally
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)){
                
                completion(contentsOfFile)
                
            }else{
                print("Couldn`t convert local image")
                completion(UIImage(named: "Avatar"))
            }
            
        }else{
            // Download from firebase
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDowloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        
                        // Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    }else{
                        print("no document in data base")
                        DispatchQueue.main.async{
                            completion(nil)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    //MARK: - Save Locally
    
    class func saveFileLocally(fileData: NSData, fileName: String){
        
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        // Means whenever thers a file in directory its override it 
        fileData.write(to: docUrl, atomically: true)
    }
    
}


//Helpers

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func fileExistsAtPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
