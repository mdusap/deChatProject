//
//  ChatViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 3/6/22.
//

/// Clase principal de la funcionalidad de los chats

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    
    //MARK: - Vistas
    // Creación de propiedades de una vista mediante código
    let leftBarButton: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        return view
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        // Ajustar texto segun tamaño de este
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        // Ajustar texto segun tamaño de este
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()
    
    
    //MARK: - Variables
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    // Para inicializar clase solo cuando nos hace falta para el audio
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    // Recoger el sender
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let refreshController = UIRefreshControl()
    
    let micButton = InputBarButtonItem()

    // Array mensajes
    var mkMessages:[MKMessage] = []
    // Array mensajes en Realm
    var allMessages: Results<Message>!
    // Variable para acceder a la base de datos de Realm
    let realm = try! Realm()
    
    //Cuantos mensajes y cuales se muestran
    var displayMessagesCount = 0
    var maxNum = 0
    var minNum = 0
    
    // Variable para el escribiendo
    var typingCounter = 0
    
    // Variable para la galeria
    var gallery: GalleryController!
    
    //MARK: - Listeners
    var notificationToken: NotificationToken?
    
    // Para cuando se pulsa el boton de audio para mandar un audio
    var longPressGesture: UILongPressGestureRecognizer!
    
    var audioFileName = ""
    var audioDuration: Date!
    
    //MARK: - Init
    // Constructor
    init(chatId: String, recipientId: String, recipientName: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Ciclo de vida del View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        createTypingObserver()
        
        configureLeftBarButton()
        configureCustomTitle()
        
        configureMessageCollectionView()
        configureGestureRecognizer()
        
        configureMessageInputBar()
        
        loadChats()
        listenForNewChats()
        listenForReadChanges()
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
        
        messageInputBar.delegate = self
        // Item en el boton de escribir de un chat
        let attachButton = InputBarButtonItem()
        // imagen del item
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        // Tamaño
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        // Accion al boton
        attachButton.onTouchUpInside{ item in
            //print("Se ha pulsado el attach button")
            self.actionAttachMessage()
        }
        
        // Boton para mandar audios
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        // Añadir funcionalidad
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButton(show: true)
        
        // Para el usuario no pueda copiar una imagen y lo ponga en el texto
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
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
        
        leftBarButton.addSubview(titleLabel)
        leftBarButton.addSubview(subTitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recipientName
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
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    //MARK: - Cargar chats antiguos
    private func checkForOldChats(){
        
        //print("Buscar chats viejos")
        // Recoger chats antiguos
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    //MARK: - Insertar mensajes
    private func listenForReadChanges(){
        
        FirebaseMessageListener.shared.listenForReadChanges(User.currentId, collectionId: chatId) { updateMessage in
            //print("Mensaje actualizado!!!!!!!!", updateMessage.message)
            //print("Estado del mensaje actualizado!!!!!!!!", updateMessage.status)
            
            // Ver si el mensaje esta leido y luego actualizamos
            if updateMessage.status != kSENT{
                
                self.updateMessage(updateMessage)
            }
            
        }
    }
    
    
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
        
        // Si el usuario que lee el mensaje que no sea el current user podra dejar en leido
        if message.senderId != User.currentId{
            markMessageRead(message)
        }
        
        //print("Mensaje insertado")
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
    
    private func markMessageRead(_ message: Message){
        
        // Si quien envia el mensaje no es el usuario actual
        if message.senderId != User.currentId && message.status != kREAD {
            //
            FirebaseMessageListener.shared.updateMessageFB(message, memberIds: [User.currentId, recipientId])
        }
    }
    
    //MARK: - Actions
    
    // Funcion para lo que el usuario puede mandar
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
       
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [User.currentId, recipientId])
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
    
    //MARK: - Typing Indicador
    func createTypingObserver(){
        
        // Estara atento a cambios para poder subirlos a firebase con respecto a la parte de escribiendo
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { isTyping in
            DispatchQueue.main.async {
                self.updateTyping(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate(){
        // Contador del Typing
        typingCounter += 1
        
        // Guardar el valor en firebase de cuando el usuario este escribiendo
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        // Parar parar el Escribiendo... despues de un rato cuando el usuario ya no este escribiendo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            // Parar de escribir
            self.typingCounterStop()
        }
    }
    
    // Funcion para cuando el usuario para de escribir
    func typingCounterStop(){
        typingCounter -= 1
        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    // Mostrar en el label debajo del nombre del usuario cuando el usuario este escribiendo
    func updateTyping(_ show: Bool){
        
        subTitleLabel.text = show ? "Typing..." : ""
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
    
    //MARK: - Actualizar estado de leido del mensaje
    // Esto cogera el mensaje...
    private func updateMessage(_ message: Message){
        //Enonctrara el mensaje
        for index in 0 ..< mkMessages.count{
            // Cogera cada mensaje
            let tempMessage = mkMessages[index]
            // Ver el mensaje que corresponde
            if message.id == tempMessage.messageId {
                // Acceder a mkmessages y le dara el status y el tiempo
                mkMessages[index].status = message.status
                mkMessages[index].readDate = message.readDate
                // Lo guardaremos en realm para asi volver a actualizar y guardar su valor
                RealmManager.shared.saveRealm(message)
        
                if mkMessages[index].status == kREAD {
                    // Actualizamos en el view
                    self.messagesCollectionView.reloadData()
                }
            }
            
        }
    }
    
    //MARK: - Helpers
    
    // Cuando el usuario salga del chat quitamos listeners de typing y mensajes
    private func removeListeners(){
        FirebaseTypingListener.shared.removeTypingListener()
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
extension ChatViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        // Si hay mas de una imagen seleccionada
        if images.count > 0 {
            images.first!.resolve { image in
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        //print("Video seleccionado")
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

