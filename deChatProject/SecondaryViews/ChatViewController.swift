//
//  ChatViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 3/6/22.
//
//  Funciones necesarias para el chat
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
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
    
    //MARK: - Listeners
    var notificationToken: NotificationToken?
    
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
        
        confirueMessageCollectionView()
        configureMessageInputBar()
        loadChats()
        
    }
    
    //MARK: - Configuraciones
    // Configuracion de mensajes
    private func confirueMessageCollectionView(){
       
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
        }
        
        // Boton para mandar audios
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        // Añadir gesture
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        // Para el usuario no pueda copiar una imagen y lo ponga en el texto
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    //MARK: - Carga de chats
    private func loadChats(){
        
        // Filtra la info de realm
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId )
        // Recoger del realm todos los mensajes ordenador
        allMessages = realm.objects(Message.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        //print("Hay, \(allMessages.count) mensajes")
        
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
    
    // Coger todos los mensajes locales y por cada convertirlos en mkMessage
   
    private func insertMessages() {
        for message in allMessages {
            insertMessage(message)
        }
    }
    
    // Divide las tareas
    private func insertMessage(_ message: Message){
        //print("Mensaje insertado")
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(message: message)!)
    }
    
    //MARK: - Actions
    
    // Funcion para lo que el usuario puede mandar
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
        
    }
}

