//
//  ProfileViewController.swift
//  CinCout
//
//  Created by Harshil Modi on 23/06/23.
//

import UIKit

class ProfileViewController: UIViewController {

    let defaults = UserDefaults.standard
    let alert = UIAlertController(title: "Error", message: "something went wrong", preferredStyle: .alert)
    
    
    @IBOutlet weak var NameTitle: UITextView!
    @IBOutlet weak var Name: UITextView!
    
    @IBOutlet weak var EmailTitle: UITextView!
    @IBOutlet weak var email: UITextView!
    
    @IBOutlet weak var misTitle: UITextView!
    @IBOutlet weak var mis: UITextView!
    
    @IBOutlet weak var DepTitle: UITextView!
    @IBOutlet weak var dept: UITextView!
    
    
    var gmis : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gmis=defaults.string(forKey: "mis")!
        
        if(defaults.bool(forKey: "profile_loaded")==false)
        {
            let url = URL(string: "http://127.0.0.1:5000/student/\(gmis)")!
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Set the request body
            //        let body: [String: String] = ["mis": mis, "password": password]
            //        let jsonData = try? JSONSerialization.data(withJSONObject: body)
            //        request.httpBody = jsonData
            
            //         Set the request headers
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //            print("hi")
                if error != nil {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Something Went Wrong", viewController: self)
                    }
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Login successful
                        //                    print("Login successful!")
                        
                        if let responseData = data {
                            do {
                                let loginResponse = try JSONDecoder().decode(Profile.self, from: responseData)
                                // Access the properties of the struct
                                //                            print("Token: \(Token.token)")
                                
                                self.defaults.set(true, forKey: "profile_loaded")
                                self.defaults.set(loginResponse.first_name, forKey: "first_name")
                                self.defaults.set(loginResponse.last_name, forKey: "last_name")
                                self.defaults.set(loginResponse.email, forKey: "email")
                                self.defaults.set(loginResponse.mis, forKey: "mis")
                                self.defaults.set(loginResponse.department, forKey: "department")
                                
                                
                                
                                // Use the loginResponse object as needed
                            } catch {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Error", message: "Something Went Wrong", viewController: self)
                                }
                            }
                        }
                    }
                    else{
                        
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Something Went Wrong", viewController: self)
                        }
                    
                    }
                }
                
            }
            task.resume()
        }
        
        DispatchQueue.main.async {
            
            self.NameTitle.isHidden=false
            self.EmailTitle.isHidden=false
            self.misTitle.isHidden=false
            self.DepTitle.isHidden=false
            
            var name = self.defaults.string(forKey: "first_name")! + " " + self.defaults.string(forKey: "last_name")!
            self.Name.text=name
            self.email.text=self.defaults.string(forKey: "email")!
            self.mis.text=self.defaults.string(forKey: "mis")!
            self.dept.text=self.defaults.string(forKey: "department")!
//                                    self.performSegue(withIdentifier: "fromLogin", sender: self)
        }
        
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
//        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//        UserDefaults.standard.synchronize()
        self.defaults.set(false, forKey: "is_logged_in")
        self.defaults.set(false, forKey: "profile_loaded")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "loginView")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    
//    let gmis : String
}
