//
//  cropDataReader.swift
//  cropTriage
//
//  Created by Blake Carr on 11/6/20.
//

import CSV
import MapKit
import Charts

// MARK: LidarDataPoint
struct LidarDataPoint{
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}


// MARK: CropDataManager
class CropDataManager{
    // MARK: data members
    let defaults = UserDefaults.standard
    // this array should hold the filenames of all CSVs that hold cropData, in order of date from the scanes
    // ie oldest -> newest
    var fileNames = Array<String>()
    var points = Array<LidarDataPoint>()
    
    // MARK: constructor
    init() {
        
        //Load Test CSV data for now
        self.fileNames = (defaults.array(forKey: "fileNameArray") ?? [""]) as! Array<String>
        
    }
    
    func saveFilenamelist(){
        for i in 0...fileNames.count-1{
            if fileNames[i] == ""{
                fileNames.remove(at: i)
                break
            }
        }
        defaults.setValue(fileNames, forKey: "fileNameArray")
    }
    
    private func clearData(){
        points.removeAll()
    }
    
    func loadCSV(fileName: String) -> Bool{
        self.clearData()
        // load CSV
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent(fileName)
        
//        guard let fileURL = Bundle.main.path(forResource: dataPath, ofType: "csv") else { return false}
//        guard let fileStream = InputStream(fileAtPath: dataPath) else {return false}
        guard let fileStream = InputStream(url: dataPath) else {return false}
        let csv = try! CSVReader(stream: fileStream, hasHeaderRow: true)
        // print header info and rows
        print("Loaded CSV with headers: \(csv.headerRow!)")
        while let row = csv.next(){
            let point = LidarDataPoint(x: Double(row[0]) ?? 0.0,
                                       y: Double(row[1]) ?? 0.0,
                                       z: Double(row[2]) ?? 0.0)
            self.points.append(point)
        }
        return true
    }

    // MARK: getters
    func getHeatMapData() -> [NSObject: Double]{
        var heatmapData: [NSObject: Double] = [:]
        for i in 0...points.endIndex-1{
            if points[i].z > 0.5{
                let coord = CLLocationCoordinate2D(latitude: points[i].x, longitude: points[i].y)
                var point = MKMapPoint(coord)
                let type = "{MKMapPoint=dd}"
                let value = NSValue(bytes: &point, objCType: type)
                heatmapData[value] = points[i].z
            }
        }
        return heatmapData
    }
    
    func getBarChartData() -> BarChartData{
        // calculate range of data
        let binCnt = 20.0
        let minVal:Double = 0
        var maxVal:Double = 0
        for i in 0...points.endIndex-1{
            if maxVal < points[i].z{
                maxVal = points[i].z
            }
        }
        // create bin ranges
        let step = maxVal/(binCnt)
        var freqRange = Array<Double>()
        for i in stride(from: minVal, through: maxVal, by: Double.Stride(step)){
            freqRange.append(i)
        }
        freqRange[freqRange.endIndex-1] = maxVal
        freqRange.remove(at: 0)
        print(freqRange)
        
        // sort values into bins
        var bins = Array(repeating: 0.0, count: Int(binCnt))
        //        print(bins)
        var binNum = 0
        for i in 0...points.endIndex-1{
            if points[i].z > freqRange[5]{
                for j in 0...freqRange.endIndex-1{
                    let rightEdge = freqRange[j]
                    if points[i].z <= rightEdge{
                        binNum = j
                        // print(binNum)
                        break;
                    }
                }
                bins[binNum] += 1
            }
        }
        
        // convert to barchatdata type
        var entries = [BarChartDataEntry]()
        for i in 0...Int(binCnt)-1{
            entries.append(BarChartDataEntry(x: freqRange[i], y: bins[i]))
            
        }
        let set = BarChartDataSet(entries: entries)
        let data = BarChartData(dataSet: set)
        return data
    }
    
}

// MARK: UI picker extension
extension CropDataManager: UIPickerViewDataSource{
    func isEqual(_ object: Any?) -> Bool {
        return false
    }
    
    var hash: Int {
        return 0
    }
    
    var superclass: AnyClass? {
        return nil
    }
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    func isProxy() -> Bool {
        return false
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return false
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return false
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return false
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return false
    }
    
    var description: String {
        return "Idk why this thing has so many goddamn protocol required functions"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fileNames.count
    }
}
