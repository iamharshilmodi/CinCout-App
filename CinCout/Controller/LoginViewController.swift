//
//  LoginViewController.swift
//  CinCout
//
//  Created by Harshil Modi on 22/06/23.
//

import UIKit
//import Parse

class LoginViewController: UIViewController {
    
        
    let defaults = UserDefaults.standard
    let alert1 = UIAlertController(title: "Error", message: "wrong mis or password entered", preferredStyle: .alert)
    let alert2 = UIAlertController(title: "Error", message: "something went wrong", preferredStyle: .alert)
    
    @IBOutlet weak var MisField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PasswordField.isSecureTextEntry = true
    }

    
    @IBAction func LoginButton(_ sender: Any) {
        
        guard let mis = MisField.text, !mis.isEmpty,
              let password = PasswordField.text, !password.isEmpty else {
            // Display an error message if any field is empty
            let alert = UIAlertController(title: "Error", message: "Please fill in both mis and password.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        defaults.set(mis, forKey: "mis")
        defaults.set(password, forKey: "password")
        
//        print(mis)
//        print(password)
        let url = URL(string: "http://127.0.0.1:5000/login")!
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the request body
        let body: [String: String] = ["mis": mis, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
//         Set the request headers
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a URLSession task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            print("hi")
            if error != nil {
                DispatchQueue.main.async {
                        
                    print("error1")
                    self.present(self.alert2, animated: true, completion: nil)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Login successful
                    print("Login successful!")
                    
                    if let responseData = data {
                        do {
                            let loginResponse = try JSONDecoder().decode(Tokens.self, from: responseData)
                            // Access the properties of the struct
                            //                            print("Token: \(Token.token)")
                            
                            self.defaults.set(true, forKey: "is_logged_in")
                            self.defaults.set(loginResponse.access_token, forKey: "access_token")
                            self.defaults.set(loginResponse.refresh_token, forKey: "refresh_token")
                            
                            DispatchQueue.main.async {
                                    
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "tabbar")
                                
                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)

                            }
                            
                            
                            // Use the loginResponse object as needed
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }  else if httpResponse.statusCode == 401 {
                    // Unauthorized - Login failed
                    DispatchQueue.main.async {
                        print("error2")
                        self.present(self.alert1, animated: true, completion: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.alert1.dismiss(animated: true, completion: nil)
                       }
                } else {
                    // Login failed with other status code
                    DispatchQueue.main.async {
                        print("error3")
                        self.present(self.alert2, animated: true, completion: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.alert2.dismiss(animated: true, completion: nil)
                       }
                }
            }

        }
        task.resume()
        
        
        
        // Start the URLSession task
    
    }
}
