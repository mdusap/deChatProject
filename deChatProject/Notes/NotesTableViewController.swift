//
//  NotesTableViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 30/5/22.
//

///  Implementacion de Notes, se pueden crear notas cortitas para algo en especifico, rapido y corto, modificar dicha nota, eliminarla, guardarla y tambien que se guarde en local, menos en firebase.


import UIKit

class NotesTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var table: UITableView!

    //MARK: - Variables
    var items = [String]()
    
    //MARK: - Text Field
    var textForUpdate: UITextField?
    
    //MARK: - Ciclo de Vida del View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registramos la celda que se usara en la tabla del screen
        table.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        // Se guardan los items en UserDefaults
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        // Boton para añadir nota
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    

    //MARK: - Acciones
    @objc private func didTapAdd(){
        
        //UIAlertController como ProgressHUD para mostrar mensajes al usuario
        let alert = UIAlertController(title:"New Item",
                                      message: "Enter a new note!",
                                      preferredStyle: .alert)
        
        //Añadimos un Text Field a la alerta para que el usuaro escriba
        alert.addTextField{ field in
            //Mensaje de hint para que el usuario sepa lo que tiene que escribir
            field.placeholder = "Enter item..."
            
        }
        
        // Acciones de cancelar o hecho
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in
            
            //Saber si el usuario ha escrito algo o lo ha dejado vacio
            if let field = alert.textFields?.first {
                
                if let text = field.text, !text.isEmpty{
                    
                    DispatchQueue.main.async {
                        //En este caso he usado UserDefaults para guardar los datos
                        var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                        // Append para añadir los datos
                        currentItems.append(text)
                        UserDefaults.standard.setValue(currentItems, forKey: "items")
                        
                        self?.items.append(text)
                        self?.table.reloadData()
                    }
                }
            }
            
        }))
        present(alert, animated: true)
    }
}

//MARK: - Extensiones

extension NotesTableViewController {
    
    //Numero de filas segun cuantos items
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    // Añado funcionalidad de borrar item
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
    
    // Si se ha pulsado sobre una nota ya escrita se podra editar la nota ...
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
