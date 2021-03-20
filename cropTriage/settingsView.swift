
//  settingsView.swift
//  cropTriage
//
//  Created by Blake Carr on 3/20/21.
//

import UIKit
import Foundation

class settingsView: UIView {
    
    let defaults = UserDefaults.standard
    var droneIP: String = "0.0.0.0"
    var dronePort: String = "25565"
    var connectionStatus: Bool = false
    
    // MARK: IB OUTLETS
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var droneIPField: UITextField!
    @IBOutlet weak var dronePortField: UITextField!
    @IBOutlet weak var connectionStatusText: UILabel!
    
    // MARK: required inits
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
    
        // Load elements from .xib
        Bundle.main.loadNibNamed("settingsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        print("Loaded setingsView.XIB")
        
        // load IP and port
        droneIP = defaults.string(forKey: "droneIP") ?? "0.0.0.0"
        dronePort = defaults.string(forKey: "dronePort") ?? "25565"
        droneIPField.text = droneIP
        dronePortField.text = dronePort
        
    }
    @IBAction func clearLidarData(_ sender: Any) {
        print("cleared Lidar Data")
        defaults.setValue([], forKey: "fileNameArray")
    
    }
    
    
    @IBAction func testDroneConnectionStatus(_ sender: Any) {
        _ = self.getState()
        
        let secondsToDelay = 2.5
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            if self.connectionStatus{
                self.connectionStatusText.text = "Connection Status: Drone connected"
            }
            else{
                self.connectionStatusText.text = "Connection Status: Drone not found"
            }
            print("This message is delayed")
            self.connectionStatus = false
        }
        
    }
    
    
    @IBAction func droneIPChanged(_ sender: UITextField) {
        print("Changed drone IP to \(String(describing: sender.text))")
        defaults.setValue(sender.text, forKey: "droneIP")
        droneIP = sender.text ?? "0.0.0.0"
    }
    
    @IBAction func dronePortChanged(_ sender: UITextField) {
        print("Changed drone Port to \(String(describing: sender.text))")
        defaults.setValue(sender.text, forKey: "dronePort")
        dronePort = sender.text ?? "25565"
    }
    
    func getState() -> [String:AnyObject] {
        let serverURL = "http://\(droneIP):\(dronePort)"
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
