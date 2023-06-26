//
//  ScanViewController.swift
//  CinCout
//
//  Created by Harshil Modi on 23/06/23.
//

import UIKit
import CoreNFC

//NFCNDEFReaderSessionDelegate
class ScanViewController: UIViewController, NFCNDEFReaderSessionDelegate, UITextFieldDelegate {
    
//class ScanViewController: UIViewController{
    
    @IBOutlet weak var reasonField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var notice: UITextView!
    

    
    @IBOutlet weak var tempbutton: UIButton!
    
    
    let defaults = UserDefaults.standard
    var nfcSession: NFCNDEFReaderSession?
    var word = "None"
//    var reason = ""
//    var destination = ""
    
    let alert = UIAlertController(title: "Error", message: "something went wrong", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reasonField.delegate = self
        destinationField.delegate = self
        
    
        
        if(defaults.bool(forKey: "is_out")==true)
        {
            reasonField.isHidden=true
            destinationField.isHidden=true
            self.tempbutton.setTitle("Check In", for: .normal)
            
        }
        else
        {
            self.tempbutton.setTitle("Check Out", for: .normal)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide the keyboard
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // Hide the keyboard when the user touches outside the keyboard area
    }
    
    @IBAction func ScanButton(_ sender: Any) {

        guard let reason = reasonField.text, !reason.isEmpty,
              let destination = destinationField.text, !destination.isEmpty else {
            // Display an error message if any field is empty
            let alert = UIAlertController(title: "Error", message: "Please fill in both reason and destination.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }

        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("The session was invalidated: \(error.localizedDescription)")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        let target = defaults.string(forKey: "target")
        for payload in messages[0].records{
            result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf8) ?? "Format not supported"
        }
        DispatchQueue.main.async {
            
            if(target==result)
            {
                self.sendData()
            }
        }
    }
    

    
    @IBAction func sendDataPressed(_ sender: Any) {
        
        sendData()
    }
        
    func sendData(){
        
        
        
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let CDate = dateFormatter.string(from: currentDate)
        
        dateFormatter.dateFormat = "HH:mm:ss"
        let CTime = dateFormatter.string(from: currentDate)

        let gmis = defaults.string(forKey: "mis")!
        
        if(defaults.bool(forKey: "is_out")==false)
        {
            guard let reason = reasonField.text, !reason.isEmpty,
                  let destination = destinationField.text, !destination.isEmpty else {
                // Display an error message if any field is empty
                let alert = UIAlertController(title: "Error", message: "Please fill in both reason and destination.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
            
            let url = URL(string: "http://127.0.0.1:5000/item/\(gmis)")!
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Set the request body
            let body: [String: String] = ["mis": gmis, "time_out": CTime, "date_out": CDate, "reason": reason, "destination": destination]
            
//            print(gmis)
//            print(CTime)
//            print(CDate)
//            print(reason)
//            print(destination)
            
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
    
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    
                if error != nil {
                    DispatchQueue.main.async {
                        print("error1")
                        self.present(self.alert, animated: true, completion: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.alert.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode == 201) || (httpResponse.statusCode == 200) {
                        // Login successful
//                        print("Login successful!")
                        
                        if let responseData = data {
                            do {
                                let loginResponse = try JSONDecoder().decode(Item.self, from: responseData)
                                // Access the properties of the struct
                                //                            print("Token: \(Token.token)")
                                
                                self.defaults.set(true, forKey: "is_out")
//                                self.defaults.set(loginResponse.access_token, forKey: "access_token")
//                                self.defaults.set(loginResponse.refresh_token, forKey: "refresh_token")
                                
                                DispatchQueue.main.async {

                                    self.reasonField.isHidden=true
                                    self.destinationField.isHidden=true
                                    self.reasonField.text=""
                                    self.destinationField.text=""
                                    self.notice.isHidden=true
                                    self.tempbutton.setTitle("Check In", for: .normal)

                                }
                                
                                
                                // Use the loginResponse object as needed
                            } catch {
                                DispatchQueue.main.async {
                                    print("error2")
                                    self.present(self.alert, animated: true, completion: nil)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }else {
                    
                        DispatchQueue.main.async {
                            print("error3")
                            self.present(self.alert, animated: true, completion: nil)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }

            }
            task.resume()
            
        }
        else
        {
//            let currentDate = Date()
//            let dateFormatter = DateFormatter()
//
//            dateFormatter.dateFormat = "dd-MM-yyyy"
//            let CDate = dateFormatter.string(from: currentDate)
//
//            dateFormatter.dateFormat = "HH:mm:ss"
//            let CTime = dateFormatter.string(from: currentDate)
//
//            let gmis = defaults.string(forKey: "mis")!
//
            let url = URL(string: "http://127.0.0.1:5000/item/\(gmis)")!
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            
            // Set the request body
            let body: [String: String] = ["mis": gmis, "time_in": CTime, "date_in": CDate]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
    
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    
                if error != nil {
                    DispatchQueue.main.async {
                        print("error1")
                        self.present(self.alert, animated: true, completion: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.alert.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode == 201) || (httpResponse.statusCode == 200) {
                        // Login successful
//                        print("Login successful!")
                        
                        if let responseData = data {
                            do {
                                let loginResponse = try JSONDecoder().decode(Item.self, from: responseData)
                                // Access the properties of the struct
                                //                            print("Token: \(Token.token)")
                                
                                self.defaults.set(false, forKey: "is_out")
                               
                                DispatchQueue.main.async {
                                
                                    self.reasonField.isHidden=false
                                    self.destinationField.isHidden=false
                                    self.notice.isHidden=true
                                    self.tempbutton.setTitle("Check Out", for: .normal)

                                }
                                
                                
                                // Use the loginResponse object as needed
                            } catch {
                                DispatchQueue.main.async {
                                    print("error3")
                                    self.present(self.alert, animated: true, completion: nil)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }else {
                    
                        DispatchQueue.main.async {
                            print("error3")
                            self.present(self.alert, animated: true, completion: nil)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }

            }
            task.resume()

        }
        
    }
}
    
//    func sendData()
    
//}
