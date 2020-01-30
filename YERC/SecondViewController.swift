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
        //print("")
        //create a new folder
       // let imgFolderURL = FileManager..appendingPathComponent("Observations")
        // get documents directory
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        let docsURL = dirPaths[0]

        let observationsDir = docsURL.appendingPathComponent("Observations")

        // check if folder already exists
        
//        FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true). It creates the directory if it doesn't exis
        if !fileManager.fileExists(atPath: observationsDir.path) {
            do{
                try fileManager.createDirectory(atPath: observationsDir.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        // make new obs url
        let newObsURL = observationsDir.appendingPathComponent("\(fileNamed).txt")
        
        // write it to disk
        do {
            let datatoWrite = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            try datatoWrite.write(to: newObsURL, options: .withoutOverwriting)
        } catch {
            print("error writing")
            debugPrint(error)
            throw Error.writtingFailed
        }

//        // make a url for the file
//        guard let url = makeURL(forFileNamed: fileNamed) else {
//            throw Error.invalidDirectory
//        }
//
//        print("in save filemanager save")
//        if fileManager.fileExists(atPath: url.absoluteString) {
//            throw Error.fileAlreadyExists
//        }
//        do {
//            print("url: ", url)
//            try data.write(to: url, options: .withoutOverwriting)
//        } catch {
//            print("error writing")
//            debugPrint(error)
//            throw Error.writtingFailed
//        }
    }
    
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func listfiles(path: String) {
        guard let url = makeURL(forFileNamed: "") else {
            print(Error.invalidDirectory)
            return
        }
        //print("listfiles URL: ", url)
        //let path1 = String(url)
        do {
           // var directory =
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .allDomainsMask)[0]
            let observationsURL = documentsURL.appendingPathComponent("Observations")
            //print("printing urls: ", observationsURL)
            //var directoryPath = fileManager.currentDirectoryPath

            //let fullPath = directoryPath + "\(path)"

            //print("fullpath: \(fullPath)")
            //directoryPath = "~/Documents"
            print("printing files: ")
            
            try print(fileManager.contentsOfDirectory(at: observationsURL, includingPropertiesForKeys: []))
//            try print(fileManager.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application/7C1B31F0-E6C8-4E80-94A0-8E53FEC863FC/Documents"))
            
            
        } catch {
            print(error)
        }
    }
    
    func read(fileNamed: String) throws -> Data {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        guard fileManager.fileExists(atPath: url.absoluteString) else {
            throw Error.invalidDirectory
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            debugPrint(error)
            throw Error.invalidDirectory
        }
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
final class FieldObservaiton: NSObject, NSCoding {
    
    // fields
    private let latitude: String
    private let longitude: String
    private let date: String
    private let time: String
    private let temp: String
    private let comment: String
    //private let photo: UIImage
    
    enum Key:String {
        case latitude = "latitude"
        case longitude = "longitude"
        case date = "date"
        case time = "time"
        case temp = "temp"
        case comment = "comment"
    }
    
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
    }
 
    //constructor
    init(lat: String, long: String, date: String, time: String, temp: String, comment: String){
         //photo: UIImage){
        self.latitude = lat
        self.longitude = long
        self.date = date
        self.time = time
        self.temp = temp
        self.comment = comment
        //self.photo = photo
    }
    
    // class must conform o NSCoding to write to file
    // needs to have an encode and a decode method
    // use encode to encodes the type into an NSCoder object.
    func encode(with coder: NSCoder) {
        coder.encode(longitude, forKey: Key.longitude.rawValue)
        coder.encode(latitude, forKey: Key.latitude.rawValue)
        coder.encode(date, forKey: Key.date.rawValue)
        coder.encode(time, forKey: Key.time.rawValue)
        coder.encode(temp, forKey: Key.temp.rawValue)
        coder.encode(comment, forKey: Key.comment.rawValue)
    }
    
    //use init to initializes the type based on decoded information from an NSCoder object.
    convenience init?(coder: NSCoder) {
        guard let longitude = coder.decodeObject(forKey: Key.longitude.rawValue) as? String else { return nil }
        guard let latitude = coder.decodeObject(forKey: Key.latitude.rawValue) as? String else { return nil }
        guard let date = coder.decodeObject(forKey: Key.date.rawValue) as? String else { return nil }
        guard let time = coder.decodeObject(forKey: Key.time.rawValue) as? String else { return nil }
        guard let temp = coder.decodeObject(forKey: Key.temp.rawValue) as? String else { return nil }
        guard let comment = coder.decodeObject(forKey: Key.comment.rawValue) as? String else { return nil }
        
        self.init(lat: latitude, long: longitude, date: date, time: time, temp: temp, comment: comment)
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
    var userEmail = ""
    @IBOutlet weak var emailLabel: UILabel!
    
    
    
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
            print("In endediting function")
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
        // add navigation bar buttons
        // the #selector calls the 'addTapped' view controller method - we must define that
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))

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
    
    // Navigation bar methods
    @objc func addTapped() {
        print("nav button pushed")
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
                    //print("inif")
                  }
                  else{
                      view.frame.origin.y = -keyboardFrame.height
                      //print("inelse")
                  }
            } else {
                //print("in other else")
                view.frame.origin.y = 0
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
    

     
    //update the text in this label right before the view will appear to the user.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
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
        print(emailLabel.text!)
        
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
    
    // Save file
    
    @IBAction func saveObservation(_ sender: Any) {
        print("in save func")
        // Check required fields
        
        // make data object
        // Create a var with key: field values of current data
        var currentObs = FieldObservaiton(lat: latLabel!.text!, long: longLabel.text!, date: dateText.text!, time: timeText.text!, temp: tempText.text!, comment: commentsText.text ?? "none")
                                          
                                          //photo: obsservationImage!)
        let fileman = FilesManager()
        
        //use time in seconds as filename
        let nowTime = Date()
        let dateformat = DateFormatter()
        dateformat.timeZone = TimeZone.current
        dateformat.dateFormat = "ss"
        let filename = dateformat.string(from: nowTime)
        //var filename = timeText.text!
        print("filename: \(filename)")
        
        
         //Save file
        do {
            try fileman.save(fileNamed: filename, data: currentObs)
        } catch {
            debugPrint(error)
            //throw Error.writtingFailed
        }
        
        //list files
        fileman.listfiles(path: filename)
        
        
        
        // clear everything and exit to home scree
        
        
    }
    

    
    //    init(lat: Double, long: Double, date: String, time: String, temp: Double, comment: String, photo: UIImage){
    
    // there should be two buttons
    // one for saving the sample without submitting
    //      -this should save into internal file system and then should be autosubmitted when
    //      phone recieves service
    // and another for submitting
    
    @IBAction func submitSample(_ sender: Any) {
        // Check that required fields are filed
        // .... TODO ...
        
        
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
    
    
    // EXIT Button
    
    @IBAction func exitToLogin(_ sender: Any) {
        // delete data and transistion to homescreen
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
    
    // SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startSegue" || segue.identifier == "exitSegue" {
            if let destinationVC = segue.destination as? ViewController {
                //destinationVC.emailTextField.insertText(emailLabel.text!)
                print("exiting to homescreen")
            }
        }
//        if segue.identifier == "exitSegue" {
//            if let destinationVC = segue.destination as? ViewController {
//                //destinationVC.emailTextField.placeholder = "Email"
//            }
//        }
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



