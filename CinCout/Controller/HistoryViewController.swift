//
//  HistoryViewController.swift
//  CinCout
//
//  Created by Harshil Modi on 23/06/23.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var table: UITableView!
    
    
    let alert = UIAlertController(title: "Error", message: "something went wrong", preferredStyle: .alert)
    
    let defaults = UserDefaults.standard
    
    struct cellData{
        let Time_out: String
        let Time_in: String
        let Date_out: String
        let Date_in: String
        let Reason: String
        let Destination: String
    }
    
    var tableData: [cellData] = []
    
    override func viewWillAppear(_ animated: Bool) {
        table.dataSource=self
        table.delegate=self
        
        table.separatorStyle = .singleLine
        table.separatorColor = .darkGray // Customize the separator color
        table.separatorInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // Customize the separator inset
        
        loadHistory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let obj = tableData[indexPath.row]
            let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! customCellTableViewCell
            
            cell.dest.text = obj.Destination
            cell.reason.text = obj.Reason
            cell.timeIn.text = obj.Time_in
            cell.timeOut.text = obj.Time_out
            cell.dateIn.text = obj.Date_in
            cell.dateOut.text = obj.Date_out
            
            return cell
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 180
        }
        //
        func loadHistory(){
            
            tableData.removeAll()
            let gmis = defaults.string(forKey: "mis")!
            
            let url = URL(string: "http://127.0.0.1:5000/all_items/\(gmis)")!
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Set the request body
            //        let body: [String: String] = ["mis": mis, "password": password]
            //        let jsonData = try? JSONSerialization.data(withJSONObject: body)
            //        request.httpBody = jsonData
            
            //         Set the request headers
            //                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //            print("hi")
                if error != nil {
                    DispatchQueue.main.async {
                        print("error2")
                        self.present(self.alert, animated: true, completion: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.alert.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Login successful
                        //                    print("Login successful!")
                        
                        if let responseData = data {
                            do {
                                let loginResponse = try JSONDecoder().decode([History].self, from: responseData)
                                // Access the properties of the struct
                                //                            print("Token: \(Token.token)")
                                
                                //                            self.defaults.set(true, forKey: "is_logged_in")
                                //                            self.defaults.set(loginResponse.access_token, forKey: "access_token")
                                //                            self.defaults.set(loginResponse.refresh_token, forKey: "refresh_token")
                                
                                DispatchQueue.main.async {
                                    
                                    for i in 0..<loginResponse.count {
                                        
                                        let TOut = loginResponse[i].time_out!
                                        let TIn = loginResponse[i].time_in ?? "No Entry"
                                        let DOut = loginResponse[i].date_out!
                                        let DIn = loginResponse[i].date_in ?? "No Entry"
                                        let rsn = loginResponse[i].reason!
                                        let dstn = loginResponse[i].destination!
                                        
                                        self.tableData.append(cellData(Time_out: TOut, Time_in: TIn, Date_out: DOut, Date_in: DIn, Reason: rsn, Destination: dstn))
                                        
                                        
                                    }
                                    
                                    
                                    self.table.reloadData()
                                    
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
                        // Login failed with other status code
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
//}
