//
//  networkManager.swift
//  cropTriage
//
//  Created by Blake Carr on 2/27/21.
//

import Foundation

class NetworkManager{
    var serverURL = "http://192.168.1.252:25565"
    let defaults = UserDefaults.standard
    var connectionStatus = false
    
    init() {
        let droneIP = defaults.string(forKey: "droneIP") ?? "0.0.0.0"
        let dronePort = defaults.string(forKey: "dronePort") ?? "25565"
        serverURL = "http://\(droneIP):\(dronePort)"
    }
    
    func scanPost(scanList: Dictionary<String,String>) -> String{
        let params = scanList
        var request = URLRequest(url: URL(string: "\(serverURL)/scan")!)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var status: String = ""
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard response != nil else { print("NETWORK ERROR"); return}
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                status = json["status"] as! String
                print(status)
            } catch {
                print("NETWORK ERROR")
            }
        })

        task.resume()
        return status
    }
    
    func scanGet() -> [String:AnyObject]{
        var request = URLRequest(url: URL(string: "\(serverURL)/scan")!)
        
        request.httpMethod = "GET"
        
        var status: [String:AnyObject] = [:]
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard response != nil else { print("NETWORK ERROR"); return}
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                status = json as [String:AnyObject]
                print(status)
            } catch {
                print("NETWORK ERROR")
            }
        })

        task.resume()
        return status
        
    }
    
    func lidarGet() -> String{
        var request = URLRequest(url: URL(string: "\(serverURL)/lidar")!)
        
        
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(Date()).csv"
        let dataPath = documentsDirectory.appendingPathComponent(fileName)
        _ = FileManager().fileExists(atPath: dataPath.path)
            
        request.httpMethod = "GET"
        
//        print(dataPath)
        let session = URLSession.shared
        let task = session.downloadTask(with: request) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let csv = try? String(contentsOf: localURL) {
//                    print(csv)
                    do {
                        try csv.write(to: dataPath, atomically: true, encoding: String.Encoding.utf8)
                        print("file has been written")
                    } catch {
                        print(error.localizedDescription)
                        print("test")
                        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                    }
                }
            }
        }

        task.resume()
        return fileName
    }
    
    func checkConnection() -> Bool{
        _ = self.getState()
        
        let secondsToDelay = 2.5
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            if self.connectionStatus{
                print("connected")
            }
            else{
                print("no connection")
            }
//            self.connectionStatus = false
        }
        return self.connectionStatus
    }
    
    func getState() -> [String:AnyObject] {
        var request = URLRequest(url: URL(string: "\(serverURL)/state")!)
        
        request.httpMethod = "GET"
        
        var status: [String:AnyObject] = [:]
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard response != nil else { print("NETWORK ERROR"); return}
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                self.connectionStatus = true
                status = json as [String:AnyObject]
                print(status)
            } catch {
                print("NETWORK ERROR")
            }
        })
        task.resume()
        
        return status
    }

}
