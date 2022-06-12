//
//  AddChannelTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 10/6/22.
//

import UIKit
import Gallery
import ProgressHUD

class AddChannelTableViewController: UITableViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    //MARK: - Variables
    var gallery: GalleryController!
    var tapGesture = UITapGestureRecognizer()
    var avatarLink = ""
    var channelId = UUID().uuidString
    
    var channelToEdit: Channel?
    
    //MARK: - Ciclo de vida del view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutTextView.delegate = self
        
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableFooterView = UIView()
        
        configureGestures()
        configureLeftBarButton()
        
        aboutTextView.text = "Write an description about your channel."
        aboutTextView.textColor = UIColor.darkGray
        
        if channelToEdit != nil {
            
            configureEditingView()
        }
    }
    
    //MARK: - IBActions
    // Cuando se pulse en el boton de guardar de o guardar canal o cauando lo edito
    @IBAction func botonSavedPressed(_ sender: Any) {
        
        if nameTextField.text != "" {
            
            channelToEdit != nil ? editChannel() : saveChannel()
        } else {
            
            ProgressHUD.showError("Channel name is empty!")
        }
    }
    
    //MARK: - Configuraciones
    // Cuando se pulse al avatar se podra poner una imagen
    private func configureGestures() {
        
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func avatarImageTap() {
        
        showGallery()
    }
    
    //MARK: - Gallery
    private func showGallery() {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    private func configureLeftBarButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    @objc func backButtonPressed() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Avatares
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.7)! as NSData, fileName: self.channelId)

        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            self.avatarLink = avatarLink ?? ""
        }
    }
    
    private func configureEditingView(){
        
        self.nameTextField.text = channelToEdit!.name
        self.channelId = channelToEdit!.id
        self.aboutTextView.text = channelToEdit!.aboutChannel
        self.avatarLink = channelToEdit!.avatarLink
        self.title = "Editing Channel"
        
        setAvatar(avatarLink: channelToEdit!.avatarLink)
    }
    
    //MARK: - Save Channel
    // Guardar el canal en firebase
    private func saveChannel() {
        
        let channel = Channel(id: channelId, name: nameTextField.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextView.text)
        
        FirebaseChannelListener.shared.saveCannel(channel)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // Poder editar el canal
    private func editChannel() {
        
        channelToEdit!.name = nameTextField.text!
        channelToEdit!.aboutChannel = aboutTextView.text
        channelToEdit!.avatarLink = avatarLink
        
        FirebaseChannelListener.shared.saveCannel(channelToEdit!)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func  setAvatar(avatarLink: String){
        
        if avatarLink != "" {
            
            FileStorage.downloadImage(imageUrl: avatarLink) { avatarImage in
                
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

}

extension AddChannelTableViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            images.first!.resolve { icon in
                
                if icon != nil{
                    
                    // Subir la imagen
                    // Ponerla como avatar
                    self.uploadAvatarImage(icon!)
                    self.avatarImageView.image = icon!.circleMasked
                }else{
                    ProgressHUD.showFailed("Couldn´t select image!")
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

extension AddChannelTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ aboutTextView: UITextView) {
        if aboutTextView.textColor == UIColor.darkGray {
            aboutTextView.text = nil
            aboutTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ aboutTextView: UITextView) {
        if aboutTextView.text.isEmpty {
            aboutTextView.text = "Write an description about your channel."
            aboutTextView.textColor = UIColor.darkGray
        }
    }
}
