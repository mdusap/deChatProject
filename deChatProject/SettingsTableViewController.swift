//
//  SettingsTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 30/5/22.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    //MARK: ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    //MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Custom header sections
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    // Space betweens sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10.0
    }
    
    //MARK: - IBActions
    @IBAction func TellAFriendButtonPressed(_ sender: Any) {
       
        
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
       
        
    }
    
    // Got back to log in when log out
    @IBAction func logOutButtonPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            if error == nil{
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
                // Get to the main thread
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    //MARK: - Update UI
    private func showUserInfo(){
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            // The app version
            appVersionLabel.text = "App version: \(Bundle.main.releaseVersionNumber ?? "")"
            
            if user.avatarLink != ""{
                // Download and set avatar image
                
            }
        }
    }
    
    

}

//MARK: -Extensions
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}