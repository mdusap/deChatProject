//
//  ChannelChatViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 11/6/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChannelChatViewController: MessagesViewController {
    
    //MARK: - Variables
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    var channel: Channel!
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    

    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    var mkMessages:[MKMessage] = []
    var allMessages: Results<Message>!
    let realm = try! Realm()
    var displayMessagesCount = 0
    var maxNum = 0
    var minNum = 0
    var gallery: GalleryController!
    
    //MARK: - Listeners
    var notificationToken: NotificationToken?
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    
    //MARK: - Init
    init(channel: Channel) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Ciclo de vida del View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        configureLeftBarButton()
        configureCustomTitle()
        
        configureMessageCollectionView()
        configureGestureRecognizer()
        
        configureMessageInputBar()
        
        loadChats()
        listenForNewChats()
    }
    // Cuando entramos en un chat
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        
    }
    // Esta funcion es para cada vez que el usuario sale del chat
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        // Parar el audio
        audioController.stopAnyOngoingPlaying()
    }
    
    //MARK: - Configuraciones
    // Configuracion de mensajes
    private func configureMessageCollectionView(){
       
        // Datos
        messagesCollectionView.messagesDataSource = self
        // Celda
        messagesCollectionView.messageCellDelegate = self
        // Display
        messagesCollectionView.messagesDisplayDelegate = self
        // Layout
        messagesCollectionView.messagesLayoutDelegate = self
        // Cuando el usuario empiece a escribir que vaya al ultimo mensaje
        scrollsToLastItemOnKeyboardBeginsEditing = true

        maintainPositionOnKeyboardFrameChanged = true

        messagesCollectionView.refreshControl = refreshController
        
    }
    
    private func configureGestureRecognizer(){
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        // Reconocer que se ha pulsado el boton como a un medio segundo
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        
    }
    
    // Personalizar la barra de mensaje
    private func configureMessageInputBar(){
        
        messageInputBar.isHidden = channel.adminId != User.currentId
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside {
            item in
            
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureLeftBarButton(){
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    func updateMicButton(show: Bool){
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            // Definir size
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }else{
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            // Definir size
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureCustomTitle(){
        
        self.title = channel.name
    }
    
    //MARK: - Carga de chats
    private func loadChats(){
        
        // Filtra la info de realm
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId )
        // Recoger del realm todos los mensajes ordenador
        allMessages = realm.objects(Message.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        //print("Hay, \(allMessages.count) mensajes")
        
        if allMessages.isEmpty{
            checkForOldChats()
        }
        
        // Notificacion para cuando cambia algo en la base de datos
        notificationToken = allMessages.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
                // Cuando accedemos a la base de datos
            case .initial:
                //print("Hay, \(self.allMessages.count) mensajes")
                self.insertMessages()
                // actualizamos el view de mensajes
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
                // Actualizamos
            case .update(_, _, let insertions, _):
                
                for index in insertions{
                    //print("Mensaje, \(self.allMessages[index].message)")
                    // Actualizar el view para ver los nuevos mensajes enviados
                    self.insertMessage(self.allMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
            case .error(let error):
                print("Error en la inserción, descr ", error.localizedDescription)
            }
        })
    }
    
    private func listenForNewChats(){
        FirebaseMessageListener.shared.listenForNewChats(chatId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    //MARK: - Cargar chats antiguos
    private func checkForOldChats(){
        
        //print("Buscar chats viejos")
        // Recoger chats antiguos
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    //MARK: - Insertar mensajes
    // Coger todos los mensajes locales y por cada convertirlos en mkMessage
    private func insertMessages() {
        
        // Recoger ultimos mensajes
        maxNum = allMessages.count - displayMessagesCount
        minNum = maxNum - kNUMBERMESSAGES
        
        // Cuando el numero minimo de mensajes sea numero negativo asi siempre el numero min de mensajes sera 0
        if minNum < 0 {
            minNum = 0
        }
        
        for i in minNum ..< maxNum{
            insertMessage(allMessages[i])
        }
        
//        for message in allMessages {
//            insertMessage(message)
//        }
    }
    
    // Divide las tareas
    private func insertMessage(_ message: Message){
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(message: message)!)
        displayMessagesCount += 1
    }
    
    // Coger el numero min y max de mensajes
    private func moreMessages(maxNumber: Int, minNumber: Int){
        maxNum = minNumber - 1
        minNum = maxNum - kNUMBERMESSAGES
        
        // Si el numero llega a 0
        if minNum < 0 {
            minNum = 0
        }
        
        for i in (minNum ... maxNum).reversed() {
            insertOldMessage(allMessages[i])
        }
    }
    
    private func insertOldMessage(_ message: Message){
        
        //print("Mensaje insertado")
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(message: message)!, at: 0)
        displayMessagesCount += 1
    }
    
    //MARK: - Actions
    // Funcion para lo que el usuario puede mandar
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.sendChannel(channel: channel, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location)
    }
    
    @objc func backButtonPressed() {
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        
        // Quitar los listeners cuando volvemos atras
        removeListeners()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // El boton izquierdo del input bar donde se podra enviar imagen, video o localizacion
    private func actionAttachMessage(){
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        // Con esto se mostraran los opciones a elegir
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { alert in
            
            //print("Has elegido camera")
            self.imageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { alert in
            
            //print("Has elegido galeria")
            self.imageGallery(camera: false)
        }
        
        let shareLoc = UIAlertAction(title: "Location", style: .default) { alert in
            
            //print("Has elegido localizacion")
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            }else{
                print("No hay acceso a la ubicación")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // Asignar a cada opcion su imagen
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.on.rectangle.angled"), forKey: "image")
        shareLoc.setValue(UIImage(systemName: "map"), forKey: "image")
        
        // Añado las opciones
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLoc)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // Delegado para el scroll de Swipe down to see more
    //MARK: - Scroll Delegados
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Ver si el usuario esta refrescando
        if refreshController.isRefreshing {
            
            if displayMessagesCount < allMessages.count {
                // Guardar mensajes de antes
                self.moreMessages(maxNumber: maxNum, minNumber: minNum)
                messagesCollectionView.reloadDataAndKeepOffset()
                
            }
            
            refreshController.endRefreshing()
        }
    }
    
    //MARK: - Helpers
    
    // Cuando el usuario salga del chat quitamos listeners de typing y mensajes
    private func removeListeners(){
        FirebaseMessageListener.shared.removeListener()
    }
    
    // Devuelve la fecha del ultimo mensaje
    private func lastMessageDate() -> Date{
        let lastMessageDate = allMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second,value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    //MARK: - Galeria
    private func imageGallery(camera: Bool){
        
        gallery = GalleryController()
        gallery.delegate = self
        // Abrir la camara
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        // Enviar solo una imagen
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        // Duracion de un video
        Config.VideoEditor.maximumDuration = 30
        
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    //MARK: - Mensajes de Audio
    @objc func recordAudio(){
        
        //print("LongPresed")
        switch longPressGesture.state {
            // En caso de que se haya pulsado el microfono
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecoder.shared.startRecording(fileName: audioFileName)
            // Cuando se suelta
        case .ended:
            
            AudioRecoder.shared.finishRecording()
        
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
                
            } else {
                print("No existe archivo de audio")
            }
            
            audioFileName = ""
            
        @unknown default:
            print("Desconocido")
        }
    }
}

// Delegado del Gallery
extension ChannelChatViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

