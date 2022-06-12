//
//  ProfileTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 2/6/22.
//

/// Clase encargada del perfil del usuario.

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - Variables
    var user: User?
    
    //MARK: - Ciclo de vida del View
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        setuUI()
    }
    
    //MARK: - Delegados de la tabla
    // "Quitar" Secciones que no necesito
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    // Distancia entre la seccion de iniciar chat y de la info del usuario
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Notificar cuando el usuario pulse una seccion
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            //print("Start chat")
            let chatId = startChat(user1: User.currentUser!, user2: user!)
            //print("El id de chat es: ", chatId)
            
            let privateChatView = ChatViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.username)

            privateChatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateChatView, animated: true)
        }
    }
    
    //MARK: - Preparacion UI
    private func setuUI(){
        
        if user != nil {
            self.title = user!.username
            usernameLabel.text = user!.username
            statusLabel.text = user!.status
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
        
    }


}
