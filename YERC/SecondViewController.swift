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

class FilesManager {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
    }
    let fileManager: FileManager
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    func save(fileNamed: String, data: FieldObservaiton) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.absoluteString) {
            throw Error.fileAlreadyExists
        }
        do {
            try data.write(to: url, options: .withoutOverwriting)
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
}

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

// Class to store observtions data
final class FieldObservaiton {
    // fields
    private let latitude: String
    private let longitude: String
    private let date: String
    private let time: String
    private let temp: String
    private let comment: String
    private let photo: UIImage
    
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
    }
 
    //constructor
    init(lat: String, long: String, date: String, time: String, temp: String, comment: String, photo: UIImage){
        self.latitude = lat
        self.longitude = long
        self.date = date
        self.time = time
        self.temp = temp
        self.comment = comment
        self.photo = photo
    }
    
    func write(to url: URL, options: Data.WritingOptions) throws {
        
    }
    
}
    
    

class SecondViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    // define variables
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var tempText: UITextField!
    @IBOutlet weak var commentsText: UITextView!
    //@IBOutlet weak var commentsText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    
    var obsservationImage: UIImage? = nil
    
    
    // Keep track of which text field is currently selected
//    var activeTextField = UITextField()
////    // Assign the newly active text field to your activeTextField variable
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//         self.activeTextField = textField
//    }

    // Send notification when temp text field is filled out - need to check that its
    // a decimal number
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.tempText {
            print("In end editing function")
            if tempText.hasText {
//                if Float(tempText.text!) == nil {
//                    print("temp must be number")
//                    let alert = UIAlertController(title: "Invalid Field", message: "Temp must be a number.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
//                    //NSLog("The \"OK\" alert occured.")
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//                } else {
//                    print("no problems")
//                }
                _ = fieldVerification()
            }
        }
    }
    
    func fieldVerification() -> Bool {
        if Float(tempText.text!) == nil {
            print("temp must be number")
            let alert = UIAlertController(title: "Invalid Field", message: "Temp must be a number.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            //NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            print("no problems")
            return true
        }
    }

    
 //create a CLLocationManager
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateText.delegate = self
        timeText.delegate = self
        tempText.delegate = self
        commentsText.delegate = self
        
        // manage keyboad covering textfield
//        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        

        
        
        // for textviews
        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.updateTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // hide key board when user taps outside of it
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        //locationManager.delegate = self
        //request location authorization when the app is in use
        //locationManager.requestWhenInUseAuthorization()
    }
    
    @objc func updateTextView(notification: Notification)
      {
          if let userInfo = notification.userInfo
          {
            if commentsText.isFirstResponder {
                let keyboardFrameScreenCoordinates = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                  
                  let keyboardFrame = self.view.convert(keyboardFrameScreenCoordinates, to: view.window)
                  
                if notification.name == UIResponder.keyboardWillHideNotification{
                      view.frame.origin.y = 0
                  }
                  else{
                      view.frame.origin.y = -keyboardFrame.height
                  }
              }
        }
      }
    
    // Keyboard display functions
//    @objc func keyboardWillShow(notification: NSNotification) {
//        print("in func")
//        if activeTextView == commentsText!{
//            print("in if")
//            print(self.commentsText.frame.minY)
//            print(self.commentsText ?? "non")
//            print(activeTextView)
//            guard let userInfo = notification.userInfo else {return}
//            guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
//            let keyboardFrame = keyboardSize.cgRectValue
//            if self.commentsText.frame.minY >= keyboardFrame.height{
//            //if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardFrame.height
//            }
//        } else {
//            print(self.commentsText ?? "non")
//            print(activeTextView)
//        }
//    }
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if activeTextView == self.commentsText!{
//            guard let userInfo = notification.userInfo else {return}
//            guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
//            let keyboardFrame = keyboardSize.cgRectValue
//            if self.commentsText.frame.minY != 0{
//            //if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardFrame.height
//            }
//        }
//    }
    
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
    
//    @IBOutlet weak var latLabel: UILabel!
//    @IBOutlet weak var longLabel: UILabel!
//    @IBOutlet weak var timeText: UITextField!
//    @IBOutlet weak var tempText: UITextField!
//    @IBOutlet weak var commentsText: UITextField!
//    @IBOutlet weak var dateText: UITextField!
    
    //    init(lat: Double, long: Double, date: String, time: String, temp: Double, comment: String, photo: UIImage){
    
    // there should be two buttons
    // one for saving the sample without submitting
    //      -this should save into internal file system and then should be autosubmitted when
    //      phone recieves service
    // and another for submitting
    
    @IBAction func submitSample(_ sender: Any) {
        // Check that required fields are filed
        // .... TODO ...
        
        // Create a var with key: field values of current data
        //var currentObs = FieldObservaiton(lat: latLabel!.text!, long: longLabel.text!, date: dateText.text!, time: timeText.text!, temp: tempText.text!, comment: commentsText.text ?? "none", photo: obsservationImage!)
        var fileman = FilesManager()
        var filename = timeText.text!
        
        
        // Save file
//        do {
//            try fileman.save(fileNamed: filename, data: currentObs)
//        } catch {
//            debugPrint(error)
//            //throw Error.writtingFailed
//        }
        
        // Call http request func
        // Check if required fields are filled out
        if tempText.hasText && dateText.hasText && timeText.hasText {
            if fieldVerification() {
                postRequest()
            } else {
                return
            }
            
        } else {
            // push an alert
            let alert = UIAlertController(title: "Mising Field", message: "Temp, Date, and Time are required to submit.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            //NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            print("required fields missing")
        }
    }
    
    func postRequest(){
        // Setup http session
        //let url = URL(string: "https://httpbin.org/post")!
        let url = URL(string: "https://rivernet-mobile.azurewebsites.net/observation")!
        //let url = URL(string: "https://localhost:8080/observation")!

        // Define request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Setup Data to be sent
        
        // set a unique file name for the photo
        // Use current time to make unique
        // date and time
        let nowTime = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        let photoTimeString = formatter.string(from: nowTime)
        //print("time: \(timeString)")
        
        let filename: String = "userPhoto-\(photoTimeString)"
                    
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        // make field name/ value pairs
        // email, lat, long, and water temp are required fields
        let fieldName = "email"
        let fieldValue = userEmail

        let fieldName2 = "latitude"
        let fieldValue2 = latLabel.text!
        
        let fieldName3 = "longitude"
        let fieldValue3 = longLabel.text!
        
        let fieldName4 = "watertemp"
        let fieldValue4 = tempText.text!
        
        // Check if comments are filled out
        let fieldName5 = "comments"
        var fieldValue5 = "None"
        if String(commentsText.text!).count != 0 {
            fieldValue5 = commentsText.text!
        }

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // Set the URLRequest to POST and to the specified URL
//        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
//        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the reqtype field and its value to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)

        // Add the lat field and its value to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue2)".data(using: .utf8)!)
        
        // Add longitude
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName3)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue3)".data(using: .utf8)!)
        
        // Add watertemp
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName4)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue4)".data(using: .utf8)!)
        
        // Add comments
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName5)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue5)".data(using: .utf8)!)

        // Add the image data to the raw http request data
        // Check if an image has been taken
        if obsservationImage == nil {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\";\"\r\n".data(using: .utf8)!)
        } else {
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename).png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
        data.append(obsservationImage!.pngData()!)
        //data.append(obsservationImage!.jpegData(compressionQuality: 1.0)!)
        }
        

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: data, completionHandler: { responseData, response, error in
                if let error = error {
                    print("error: \(error)")
                } else {
                    if let response = response as? HTTPURLResponse {
                        print("statusCode: \(response.statusCode)")
                    }
                    guard let data = responseData, error == nil else {
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
            
//            if(error != nil){
//                print("\(error!.localizedDescription)")
//            }
//
//            guard let responseData = responseData else {
//                print("no response data")
//                return
//            }
//
//            if let responseString = String(data: responseData, encoding: .utf8) {
//                print("uploaded to: \(responseString)")
//            }
        }).resume()
    }
    
    
    
    
    
    
    
    func JSONsubmitToServe(){
        
        // setup JSON
        //let json = "{data: {lat: 37.7, long: -122.4, date: 2019-12-18, time: 10:26:17}, comments: weom thins goninset oiansg}"
        //let json: [String: Any] = ["title": "ABC",
        //                           "dict": ["1":"First", "2":"Second"]]

        //let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // set post string
        // email, latitude, longitude, watertemp, image, comments
        let postString = "email=\(userEmail)&latitude=\(latLabel.text!)&longitude=\(longLabel.text!)&watertemp=\(tempText.text!)&image=&comments=\(commentsText.text ?? "none")"
        //lat: latLabel!.text!, long: longLabel.text!, date: dateText.text!, time: timeText.text!, temp: tempText.text!, comment: commentsText.text ?? "none"
        
        //let url = URL(string: "https://httpbin.org/post")!
        let url = URL(string: "https://rivernet-mobile.azurewebsites.net/observation")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set header fields
        let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        var body = ""
        body += "--\(boundary)\r\n"
        body += "Content-Disposition: form-data; name=\"email\"; value=\"\(userEmail)\"\r\n"

        //var boundary = generat
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set request body
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);

        //request.httpBody = jsonData
        
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
    
    
    @IBOutlet weak var imagePrev: UIImageView!
    
    // function for camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        obsservationImage = image
        // print out the image size as a test
        print(image.size)
        
        // Set image view
        imagePrev.image = obsservationImage
        imagePrev.layer.cornerRadius = 5
        imagePrev.clipsToBounds = true
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



