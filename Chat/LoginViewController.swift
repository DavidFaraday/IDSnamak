//
//  LoginViewController.swift
//  Chat
//
//  Created by David Kababyan on 03/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //MARK: - IBOutlet
    //labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabelOutlet: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //textFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    //views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    //MARK: - Vars
    var isLogin = true
    var notificationController: NotificationController!

    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationController = NotificationController(_view: self.view)

        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroundTap()
    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            isLogin ? loginUser() : registerUser()
        } else {
            self.notificationController.showNotification(text: "All fields are required.", isError: true)
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            self.notificationController.showNotification(text: "Email is required.", isError: true)
        }
    }
    

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            resendVerificationEmail()
        } else {
            self.notificationController.showNotification(text: "Email is required.", isError: true)
        }
    }
    
    //MARK: - Animations
    private func updateUIFor(login: Bool) {
        
        self.loginButtonOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        self.signUpButtonOutlet.setTitle(login ? "SignUp" : "Login", for: .normal)
        
        self.signUpLabel.text = login ? "Don't have an account?" : "Have an account?"
                
        UIView.animate(withDuration: 0.5) {
            
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabelOutlet.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
    }

    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        case emailTextField:
            emailLabelOutlet.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabelOutlet.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabelOutlet.text = textField.hasText ? "Repeat Password" : ""
        }
        
    }

    
    //MARK: - Setup
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

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
    
    //MARK: - Helpers
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                if  isEmailVerified {
                    self.goToApp()
                } else {
                    self.notificationController.showNotification(text: "Please verify email.", isError: true)
                    self.resendEmailButtonOutlet.isHidden = false
                }
            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
        }
    }

    private func registerUser() {
        FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {
                self.notificationController.showNotification(text: "Verification email sent", isError: false)
                self.resendEmailButtonOutlet.isHidden = false

            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
        }
    }

    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                self.notificationController.showNotification(text: "Reset link sent to email.", isError: false)
            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
            if error == nil {
                self.notificationController.showNotification(text: "New verification email sent", isError: false)
            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
        }
    }
    
    private func isDataInputedFor(type: String) -> Bool {
        
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "register":
            
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    //MARK: - Navigation
    private func goToApp() {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }

}

