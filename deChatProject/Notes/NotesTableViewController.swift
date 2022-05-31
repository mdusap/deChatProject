//
//  NotesTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 30/5/22.
//

import UIKit

class NotesTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var table: UITableView!

    
    //MARK: - Vars
    var items = [String]()
    
    //MARK: - Text Field
    var textForUpdate: UITextField?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cell
        table.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    

    //MARK: - Action
    @objc private func didTapAdd(){
        
        //UIAlertController is an object that displays an alert message to the user.
        let alert = UIAlertController(title:"New Item",
                                      message: "Enter a new note!",
                                      preferredStyle: .alert)
        
        //Adding a text field to the alert object
        alert.addTextField{ field in
            //Hint message that says what the user should input
            field.placeholder = "Enter item..."
            
        }
        
        //Adding two differetn action for the user to do with the alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        //We use WEAK SELF to not cause a memory leak most used to avoud strong reference cycles
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in
            
            //To know if the user had write a text or not
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty{
                    //Enter new to do list item
                    //This referes how the task is handled, Synchronous function returns the control on the current queue only after task is finished
                    DispatchQueue.main.async {
                        //User Defaults to save the data
                        var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                        currentItems.append(text)
                        UserDefaults.standard.setValue(currentItems, forKey: "items")
                        
                        self?.items.append(text)
                        self?.table.reloadData()
                    }
                }
            }
            
        }))
        
        //This one Presents a view controller modally. in this case it will present alert modally
        present(alert, animated: true)
    }
}

//MARK: - Extension

extension NotesTableViewController {
    
    //Obligatory functions of the table, the number of rows it has to have and the cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //textLabel it will be deprecated in next version of IOS
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
            
            self.items.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .fade)
            
            DispatchQueue.main.async {
                
                var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                currentItems.remove(at: indexPath.row)
                UserDefaults.standard.setValue(currentItems, forKey: "items")
                
                self.table.reloadData()
            }
            
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemSelected = items[indexPath.row]
        
        let alert = UIAlertController(title:"Edit Operation",
                                      message: "Edit this note!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] (_) in
            
            let updatedItem = self?.textForUpdate?.text!
            self?.items[indexPath.row] = updatedItem ?? ""
            
            DispatchQueue.main.async {
                
                var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                currentItems.remove(at: indexPath.row)
                currentItems.append(updatedItem!)
                UserDefaults.standard.setValue(currentItems, forKey: "items")
                
                
                self?.table.reloadData()
            }
            
        }))
        
        alert.addTextField{ (textfield) in
            
            self.textForUpdate = textfield
            self.textForUpdate?.placeholder="Update note here..."
            self.textForUpdate?.text=itemSelected
        }
        present(alert,animated: true, completion: nil)
    }
}
