//
//  ViewController.swift
//  YERC
//
//  Created by Joseph Akers on 11/18/19.
//  Copyright © 2019 Joseph Akers. All rights reserved.
//

import UIKit


// viewController is subclass of UIViewcontroller class
class ViewController: UIViewController, UITextFieldDelegate {
    
    //defiine fields
    
    // same email address to a const
    //let userEmail;
    @IBOutlet weak var emailTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        // Do any additional setup after loading the view.
        //emailTextField.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // add action from start sample button
    
    @IBAction func startSample(_ sender: Any) {
        // add code to execute when buttom is pressed
        let text: String = emailTextField.text ?? ""
        if text.isEmpty {
           // nothing entered
            print("enter some text")
            emailTextField.placeholder = "Enter A Valid Email"
            
            
        } else {
            // myTextField not empty
            print("text entered: \(text)")
            if isValid(text){
                // email is good
                // take user to next page
                print("email is valid: \(text)")
                //performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
                //shouldPerformSegue(withIdentifier: "startSampleSegue, sender: <#T##Any?#>)
                
                performSegue(withIdentifier: "startSampleSegue", sender: nil)
            }
            else {
                print("email is invalid: \(text)")
                emailTextField.text = ""
                emailTextField.placeholder = "Enter A Valid Email"
            }
                
        }
            
        }
    
    // fix orientation to portrait
    // Set the shouldAutorotate to False
    override open var shouldAutorotate: Bool {
       return false
    }

    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
    

    /// Validate email string
    ///
    /// - parameter email: A String that rappresent an email address
    ///
    /// - returns: A Boolean value indicating whether an email is valid.
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
// prepare for segue
    
    // Add unwind seque action method so xcode know this view controller will be a destination
    //@IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){}
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showItemSegue" {
//            let navController = segue.destination as! UINavigationController
//            let detailController = navController.topViewController as! ShowItemViewController
//            detailController.currentId = nextId!
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("printing: ", emailTextField.text!)
        if segue.identifier == "startSampleSegue" {
            let navController = segue.destination as! UINavigationController
            
            let destinationVC = navController.viewControllers.first as! SecondViewController

            //var destinationVC = navController.topViewController {
            //}
            //if let destinationVC = segue.destination as? SecondViewController {
                
                destinationVC.userEmail = emailTextField.text ?? "unknown"
        }
    }
    

}

