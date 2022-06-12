//
//  ViewController.swift
//  deChatProject
//
//  Created by Dusa, Maria Paula on 28/5/22.
//

/// Contiene el codigo para poder realizar el login

import UIKit
import Firebase
import ProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    //labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //textFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    //Vies
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    //MARK: - Variables
    var isLogin = true
    var iconClick = true
    
    //MARK: - Ciclo de vida del View
    override func viewDidLoad() {
        super.viewDidLoad()
       
        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroundTap()
    }
    
    //MARK: - IBActions
    // Si se ha pulsado del boton de login
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("Fill all fields please.")
        }
    }
    
    // Si se ha pulsado que se ha olvidado contraseña
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required.")
        }
    }
    
    // Si se ha pulsado para volver a enviar un email de verificacion
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
            if isDataInputedFor(type: "password") {
                resendVerificationEmail()
            } else {
                ProgressHUD.showFailed("Email is required.")
            }
    }
    
    // Boton de registrartse
    @IBAction func signUpButtonPressed(_ sender: Any) {
        updateUIFor(login: (sender as AnyObject).titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    //MARK: - Preparacion del screen
    // Lo que hara cada text field segun su target...
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }

    //...En este caso se actualizara su placeholder
    @objc func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
    
    //MARK: - Animaciones
    // Actualizar UI segun elecciones del usuario
    private func updateUIFor(login: Bool) {
        
        loginButtonOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpButtonOutlet.setTitle(login ? "SignUp" : "Login", for: .normal)
        
        signUpLabel.text = login ? "Don't have an account?" : "Have an account?"
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
        
    }
    
    // Actualizar los placeholder segun si el usuario ha pulsado uno o no
    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        case emailTextField:
            emailLabelOutlet.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabelOutlet.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        }
        
    }

    
    //MARK: - Helpers
    // Devolver los valores si no estan vacios
    private func isDataInputedFor(type: String) -> Bool {
        
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
        
    }
    
    // Log In
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                if isEmailVerified {
                    
                    self.goToApp()
                } else {
                    ProgressHUD.showFailed("Please verify email.")
                    self.resendEmailButtonOutlet.isHidden = false
                }
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
            
        }
    }

    // Registrar usuario
    private func registerUser() {
        
        if passwordTextField.text! == repeatPasswordTextField.text! {
            
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                
                if error == nil {
                    ProgressHUD.showSuccess("Verification email sent!")
                    self.resendEmailButtonOutlet.isHidden = false
                } else {
                    ProgressHUD.showFailed(error!.localizedDescription)
                }
            }
            
        } else {
            ProgressHUD.showFailed("Sorry but passwords don´t match :(")
        }
    }
    
    // Resetear contraseña
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent!")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    // Volver a enviar email de verificacion
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.showSuccess("New verification email sent!")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
                print(error!.localizedDescription)
            }
        }
    }
    
    //MARK: - Navigacion
    private func goToApp() {
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    

}

