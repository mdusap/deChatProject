//
//  EditProfileTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 31/5/22.
//

/// Esta clase corresponde con el boton Edit de la pantalla de Settings


import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    
    //MARK: - Vars
    var gallery: GalleryController!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        configureTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Headers personalizados
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 30.0
    }
    
    // Cada vez que el usuario pulse una celda
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Ir a la tabla de status
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "editProfileToStatus", sender: self)
        }
    }
    
    //MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        showImageGallery()
    }
    
    
    //MARK: - Update UI
    
    private func showUserInfo(){
        if let user = User.currentUser {
            userNameTextField.text = user.username
            statusLabel.text = user.status
            
            if user.avatarLink != "" {
                // Set avatar
                FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    //MARK: - Configure
    
    private func configureTextField(){
        userNameTextField.delegate = self
        userNameTextField.clearButtonMode = .whileEditing
    }
    
    //MARK: - Gallery
    
    private func showImageGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        // Elegir una imagen o camara con limite 1
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    //MARK: - Upload Images
    private func uploadAvatarImage(_ image: UIImage){
        
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            
            if var user = User.currentUser {
                
                user.avatarLink = avatarLink ?? ""
                
                saveUserLocally(user)
                // Chequear rules si esto da problemas
                FirebaseUserListener.shared.saveUserToFireStore(user)
                
            }
            
            // Guardar imagen de manera local
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
            
        }
    }
}

//MARK: - Extension
extension EditProfileTableViewController: UITextFieldDelegate, GalleryControllerDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userNameTextField {
            if textField.text != ""{
                if var user = User.currentUser {
                    user.username = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            }
            
            // Dismiss teclado
            textField.resignFirstResponder()
            return false
            
        }
        
        return true
        
    }
    
    // CONTROLLER DELEGATE GALLERY FUNCIONES
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            
            images.first!.resolve { (avatarImage) in
                if avatarImage != nil {
                    self.uploadAvatarImage(avatarImage!)
                    self.avatarImageView.image = avatarImage?.circleMasked
                }else{
                    ProgressHUD.showError("Couldn´t select image!")
                }
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
