//
//  SecondViewController.swift
//  YERC
//
//  Created by Joseph Akers on 12/12/19.
//  Copyright © 2019 Joseph Akers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


final class CustomButton: UIButton {

    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
            shadowLayer.fillColor = UIColor.lightGray.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }

}

class SecondViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // define variables
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var tempText: UITextField!
    @IBOutlet weak var commentsText: UITextField!
    
    @IBOutlet weak var dateText: UITextField!
    

    
 //create a CLLocationManager
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateText.delegate = self
        timeText.delegate = self
        tempText.delegate = self
        commentsText.delegate = self
        
        // manage keyboad covering textfield
        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // hide key board when user taps outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        //locationManager.delegate = self
        //request location authorization when the app is in use
        //locationManager.requestWhenInUseAuthorization()
    }
    
    // Keyboard display functions
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height
        }

    }
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    //print("somethinga")
    
    var userEmail = ""
    
    @IBOutlet weak var emailLabel: UILabel!
     
    //update the text in this label right before the view will appear to the user.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // date and time
        let nowDate = Date()
        let nowTime = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: nowTime)
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: nowDate)
        print("time: \(timeString)")
        print("Date: \(dateString)")
        // Display in app
        timeText.text = timeString
        dateText.text = dateString
        
        

     
        emailLabel.text = "Welcome \(userEmail)."
        //print("hello")
        
        // get current location
        determineCurrentLocation()
    }
    // *** BUTTONS ****
    // access Camera
    @IBAction func addPicture(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    @IBAction func submitSample(_ sender: Any) {
        
        // setup JSON
        //let json = "{data: {lat: 37.7, long: -122.4, date: 2019-12-18, time: 10:26:17}, comments: weom thins goninset oiansg}"
        let json: [String: Any] = ["title": "ABC",
                                   "dict": ["1":"First", "2":"Second"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://httpbin.org/post")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }

//                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("data: \(dataString)")
//                }
            }
        }
        task.resume()
        //hitAPI(_for: "https://httpbin.org/post")
        
    }
    
    // HTTP request
//    func hitAPI(_for URLString:String) {
//       //let configuration = URLSessionConfiguration.default
//       //let session = URLSession(configuration: configuration)
//       let url = URL(string: URLString)!
//       //let url = NSURL(string: urlString as String)
//       var request = URLRequest(url: url)
//       request.httpMethod = "POST"
//        //print("headers: \(String(describing: request.allHTTPHeaderFields))")
//        //print("method: \(request.httpMethod ?? "something")")

//        print(request)
//        //print(request.httpBody!)
//
//        let dataTask = URLSession.shared.dataTask(with: url) {
//          data,response,error in
//          // 1: Check HTTP Response for successful GET request
//          guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
//          else {
//             print("error: not a valid http response")
//             return
//          }
//
//        print("status code: \(httpResponse.statusCode)")
//
//          switch (httpResponse.statusCode) {
//             case 200:
//                print("respose code 200")
//                print(receivedData)
//                break
//             case 400:
//                print("respose code 400")
//                break
//             default:
//                print("respose DEFAULT")
//                break
//          }
//       }
//       dataTask.resume()
//    }
    
    
    
    // function for camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
    
    func determineCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
       // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        latLabel.text = String(userLocation.coordinate.latitude)
        print("user longitude = \(userLocation.coordinate.longitude)")
        longLabel.text = String(userLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



