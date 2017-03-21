//
//  HTTP.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/21/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import UIKit

import UIKit

class HTTP: NSObject {
    
    /* HTTP POST REQUEST */
    
    func POST (_ url: String, requestJSON: Data, postComplete: @escaping (_ success: Bool, _ msg: String) -> ()) {
        // Set up the request object
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = requestJSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Initialize session object
        guard let requestUrl = URL(string: url) else { return }
        let session = URLSession.shared
        
        let task = session.dataTask(with: requestUrl) {
            (data, response, error) in
            
            if error == nil {
                postComplete(false, "ERROR")
                print("Error data is nil")
            }
            
            let parsed = self.fromJSON(data!)
            if let responseData = parsed {
                let success = responseData["status"] as! String
                
                if (success == "Successfully uploaded!") {
                    postComplete(true, "SUCCESS")
                    print("\(responseData)")
                } else {
                    postComplete(false, "FAILURE")
                    print("\(responseData)")
                }
            } else {
                postComplete(false, "ERROR")
                print("Error in response!")
            }
        }
        task.resume()
    }
    
    
    /* HTTP GET REQUEST */
    
    func GET (_ url: String, requestJSON: Data, postComplete: @escaping (_ success: Bool, _ msg: String) -> ()) {
        // Set up the request object
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.httpBody = requestJSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Initialize session object
        guard let requestUrl = URL(string: url) else { return }
        let session = URLSession.shared
        
        let task = session.dataTask(with: requestUrl) {
            (data, response, error) in
            
            if error == nil {
                postComplete(false, "ERROR")
                print("Error data is nil")
            }
            
            let parsed = self.fromJSON(data!)
            if let responseData = parsed {
                let success = responseData["status"] as! String
                
                if (success == "Successfully uploaded!") {
                    postComplete(true, "SUCCESS")
                    print("\(responseData)")
                } else {
                    postComplete(false, "FAILURE")
                    print("\(responseData)")
                }
            } else {
                postComplete(false, "ERROR")
                print("Error in response!")
            }
        }
        task.resume()
    }
    
    /* HTTP DELETE REQUEST */
    
    func DELETE (_ url: String, requestJSON: Data, postComplete: @escaping (_ success: Bool, _ msg: String) -> ()) {
        // Set up the request object
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        request.httpBody = requestJSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Initialize session object
        guard let requestUrl = URL(string: url) else { return }
        let session = URLSession.shared
        
        let task = session.dataTask(with: requestUrl) {
            (data, response, error) in
            
            if error == nil {
                postComplete(false, "ERROR")
                print("Error data is nil")
            }
            
            let parsed = self.fromJSON(data!)
            if let responseData = parsed {
                let success = responseData["status"] as! String
                
                if (success == "Successfully uploaded!") {
                    postComplete(true, "SUCCESS")
                    print("\(responseData)")
                } else {
                    postComplete(false, "FAILURE")
                    print("\(responseData)")
                }
            } else {
                postComplete(false, "ERROR")
                print("Error in response!")
            }
        }
        task.resume()
    }
    
    
    
    
    /* JSON CONVERSION */
    
    func toJSON (_ dict: NSDictionary) -> Data? {
        if JSONSerialization.isValidJSONObject(dict) {
            do {
                let json = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
                return json
            } catch let error as NSError {
                print("ERROR: Unable to serialize json, error: \(error)")
            }
        }
        return nil
    }
    
    func fromJSON (_ JSON: Data) -> NSDictionary? {
        do {
            return try JSONSerialization.jsonObject(with: JSON, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch {
            return nil
        }
    }
    
}

