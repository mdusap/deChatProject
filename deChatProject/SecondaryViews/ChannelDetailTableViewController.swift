//
//  ChannelTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 11/6/22.
//

import UIKit

protocol ChannelDetailTableViewControllerDelegate {
    func didClickFollow()
}

class ChannelDetailTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    //MARK: - Variables
    var channel: Channel!
    var delegate: ChannelDetailTableViewControllerDelegate?
    
    //MARK: - Ciclo de Vida del View
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        showChannelData()
        configureRightBarButton()
       
    }
    
    //MARK: - Configure
    // Muestra info del canal
    private func showChannelData() {
        self.title = channel.name
        nameLabel.text = channel.name
        membersLabel.text = "\(channel.memberIds.count) Members"
        aboutTextView.text = channel.aboutChannel
        setAvatar(avatarLink: channel.avatarLink)
    }
    
    private func configureRightBarButton() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followChannel))
    }

    // Le pone el avatar
    private func setAvatar(avatarLink: String) {

        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in

                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

    
//    MARK: - Actions
    @objc func followChannel() {
        channel.memberIds.append(User.currentId)
        FirebaseChannelListener.shared.saveCannel(channel)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }

}
