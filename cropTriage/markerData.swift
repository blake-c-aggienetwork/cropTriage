//
//  markerData.swift
//  cropTriage
//
//  Created by Blake Carr on 10/10/20.
//

import Foundation
import MapKit

// MARK: marker data manager
class MarkerDataManger {
    
    var latArr: Array<Double>
    var longArr: Array<Double>
    var isWayPointArr: Array<Bool>
    
    var pinArr = Array<MKPointAnnotation>()
    var circleArr = Array<MKCircle>()
    
    
    let defaults = UserDefaults.standard
    
    init() {
        // Load arrays with saved data
        latArr = defaults.array(forKey: "latArr") as? Array<Double> ?? Array<Double>()
        longArr = defaults.array(forKey: "longArr") as? Array<Double> ?? Array<Double>()
        isWayPointArr = defaults.array(forKey: "isWayPoint") as? Array<Bool> ?? Array<Bool>()
        
        // transfer array data into usable MK objects
        if latArr.endIndex-1 >= 0{
            for i in 0...latArr.endIndex-1{
                let coord = CLLocationCoordinate2D(latitude: latArr[i], longitude: longArr[i])
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coord
                pinArr.append(annotation)
                
                let circle = MKCircle(center: coord, radius: 25)
                circleArr.append(circle)
            }
        }
        
    }
    
    func saveData(){
        print("Saving Marker Data")
        defaults.setValue(latArr, forKey: "latArr")
        defaults.setValue(longArr, forKey: "longArr")
        defaults.setValue(isWayPointArr, forKey: "isWayPointArr")
    }
    
    func pinMoved(){
        print("Pin moved, refreshing saved data")
        for i in 0...pinArr.endIndex-1{
            let pinLat = pinArr[i].coordinate.latitude
            let pinLong = pinArr[i].coordinate.longitude
            if pinLat != latArr[i] && pinLong != longArr[i]{
                latArr[i] = pinLat
                longArr[i] = pinLong
            }
        }
        
        saveData()
        
    }
    
    func getDict() -> Dictionary<String, String>{
        var scanDict: Dictionary<String,String> = [:]
        
        for i in 0...getPinCnt()-1{
            scanDict["\(i+1)"] = "\(getPin(at: i).coordinate.latitude),\(getPin(at: i).coordinate.longitude)"
        }
        
        return scanDict
    }
    
    func getPin(at: Int) -> MKPointAnnotation{
        return pinArr[at]
    }
    
    func getLastPin() -> MKPointAnnotation {
        return pinArr.last ?? MKPointAnnotation()
    }
    
    func getCircle(at: Int) -> MKCircle{
        return circleArr[at]
    }
    
    func getLastCircle() -> MKCircle{
        return circleArr.last ?? MKCircle()
    }
    
    func getIsWayPoint(at: Int) -> Bool {
        return isWayPointArr[at]
    }
    
    func getPinCnt() -> Int {
        return pinArr.count
    }
    
    func addPoint(lat: Double, long: Double, isWayPoint: Bool){
        latArr.append(lat)
        longArr.append(long)
        isWayPointArr.append(isWayPoint)
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        
        pinArr.append(annotation)
        
        let circle = MKCircle(center: coord, radius: 25)
        circleArr.append(circle)
        
        saveData()
    }
    
    func overwriteCircle(at: Int, circle: MKCircle){
        circleArr[at] = circle
        saveData()
    }
    
    func deleteAllPins(){
        pinArr.removeAll()
        circleArr.removeAll()
        latArr.removeAll()
        longArr.removeAll()
        isWayPointArr.removeAll()
        
        saveData()
        
    }
    
}
