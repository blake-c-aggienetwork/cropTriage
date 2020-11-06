//
//  cropDataReader.swift
//  cropTriage
//
//  Created by Blake Carr on 11/6/20.
//

import Foundation
import CSV
import MapKit

class cropDataManager{
    // MARK: data members
    let defaults = UserDefaults.standard
    // this array should hold the filenames of all CSVs that hold cropData, in order of date from the scanes
    // ie oldest -> newest
    var fileNames = Array<String>()
    var points = Array<Array<Double>>()
    
    
    
    // MARK: constructor
    init() {
        
        //Load Test CSV data for now
        self.fileNames.append("ideal_raspberrypi_output")
        self.loadCSV(fileName: fileNames[0])
        
    }
    
    private func loadCSV(fileName: String){
        // load CSV
        let fileURL = Bundle.main.path(forResource: fileName, ofType: "csv")!
        let fileStream = InputStream(fileAtPath: fileURL)!
        let csv = try! CSVReader(stream: fileStream, hasHeaderRow: true)
        // print header info and rows
        print("Loaded CSV with headers: \(csv.headerRow!)")
        while let row = csv.next(){
            let doubleArray = [Double(row[0])!,Double(row[1])!,Double(row[2])!]
            self.points.append(doubleArray)
        }
    }
    
    func getHeatMapPoint(at: Int) -> NSDictionary {
        // Get point location
        let lat: CLLocationDegrees = points[at][0]
        let long: CLLocationDegrees = points[at][1]
        let point: MKMapPoint = MKMapPoint(x: lat, y: long)
        // Get weight
        let weight: Double = points[at][2]
        // return dict
        let dict: NSDictionary = [point: weight]
        return dict
    }
    
    func getHeatMapPointsDict() -> NSDictionary{
        let mutableDict: NSMutableDictionary = NSMutableDictionary()
        for i in 0...points.endIndex-1{
            // Get point location
            let lat: CLLocationDegrees = points[i][0]
            let long: CLLocationDegrees = points[i][1]
            let point: MKMapPoint = MKMapPoint(x: lat, y: long)
            // Get weight
            let weight: Double = points[i][2]
            // add dict
            let dict: NSMutableDictionary = [point: weight]
            mutableDict.addEntries(from: dict as! [AnyHashable : Any])
        }
        let finalDict = NSDictionary(dictionary: mutableDict)
        return finalDict
    }
    
    
}
