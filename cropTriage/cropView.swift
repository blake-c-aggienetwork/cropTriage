//
//  cropView.swift
//  cropTriage
//
//  Created by Blake Carr on 11/2/20.
//

import UIKit
import MapKit
import DTMHeatmap
import Charts

class cropView: UIView, ChartViewDelegate {
    
    // MARK: data members
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    let defaults = UserDefaults()
    var mapTypeIndex: Int = 0
    var cropManager: CropDataManager = CropDataManager()
    var network = NetworkManager()
    var barChart = BarChartView()
    
    
    // IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var dataSelector: UIPickerView!
    
    
    // MARK: IB ACTIONS
    @IBAction func selectedNewMapType(_ sender: UISegmentedControl) {
        print("User changing mapType")
        mapTypeIndex = mapTypeSelector.selectedSegmentIndex
        defaults.setValue(mapTypeIndex, forKey: "mapTypeIndex")
        switch mapTypeIndex {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = MKMapType.hybrid
        case 2:
            mapView.mapType = MKMapType.satellite
        default:
            mapView.mapType = MKMapType.standard
        }
    }
    
    @IBAction func loadTestData(_ sender: Any) {
        // Data manager will load selected data
        if cropManager.fileNames.isEmpty{
            return
        }
        let selectedDataIndex = dataSelector.selectedRow(inComponent: 0)
        print("Loading data from: " + cropManager.fileNames[selectedDataIndex])
        if cropManager.loadCSV(fileName: cropManager.fileNames[selectedDataIndex]) == false{
            print("Data Failed to load")
            
            return
        }
        
        // Clear heatMaps
        if mapView.overlays.count >= 1{
            print("removing overlays")
            mapView.removeOverlays(mapView.overlays)
        }
        
        let heatMapOverlay = DTMHeatmap()
        let heatMapData = cropManager.getHeatMapData()
        heatMapOverlay.setData(heatMapData as [NSObject: AnyObject])
        //        let colorProvider = DTMColorProvider()
        //        heatMapOverlay.colorProvider =
        //        have not figured out how to configure heatmap colors yet
        mapView.addOverlay(heatMapOverlay)
        
        print("Added Heat Map Overlay")
        
        
        let chartData = cropManager.getBarChartData()
        //        chartData.barWidth = 10
        chartData.highlightEnabled = false
        barChart.data = chartData
        
        print("Bar Chart data updated")
    }
    
    @IBAction func downloadScan(){
        let connectionStatus = network.checkConnection()
        let secondsToDelay = 2.5
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            print("This message is delayed")
            if connectionStatus{
                let fileName = self.network.lidarGet()
                self.cropManager.fileNames.insert(fileName, at: 0)
                self.cropManager.saveFilenamelist()
                
                self.dataSelector.reloadAllComponents()
            }else{
                print("no connection to server, download aborted")
            }
        }
        
        
    }
    
    
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
        Bundle.main.loadNibNamed("cropView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        print("Loaded cropView.XIB")
        
        self.initMap() // init map
        self.initChart() // init chart
        self.initDataPicker() // init data picker
        
        controlView.layer.cornerRadius = 10 // edit control view properties
        
    }
    
    // MARK: data picker config
    private func initDataPicker(){
        dataSelector.dataSource = cropManager
        dataSelector.delegate = self
        
        dataSelector.reloadAllComponents()
    }
    
    
    // MARK: chart config
    private func initChart(){
        
        barChart.delegate = self // This view acts on behalf of the chart view
        barChart.frame = CGRect(x: 15, y: 365, width: controlView.frame.size.width-30, height: 300)
        //        barChart.center = chartViewHolder.center
        
        controlView.addSubview(barChart)
        
        barChart.noDataText = ""
        
        barChart.pinchZoomEnabled = false
        barChart.setScaleEnabled(false)
        barChart.drawValueAboveBarEnabled = false
        barChart.fitBars = true
    }
    
    // MARK: map config
    private func initMap(){
        // configure map properties
        
        // load mapType saved from userDefaults
        mapTypeIndex = defaults.value(forKey: "mapTypeIndex") as? Int ?? 0
        switch mapTypeIndex {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = MKMapType.hybrid
        case 2:
            mapView.mapType = MKMapType.satellite
        default:
            mapView.mapType = MKMapType.standard
        }
        mapTypeSelector.selectedSegmentIndex = mapTypeIndex
        
        mapView.delegate = self
        let cameraZoom = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 500, maxCenterCoordinateDistance: 10000)
        mapView.setCameraZoomRange(cameraZoom, animated: true)
        mapView.layer.cornerRadius = 10
        mapView.layer.shadowColor = UIColor.black.cgColor
        mapView.layer.shadowOpacity = 1
        mapView.layer.shadowOffset = .zero
        mapView.layer.shadowRadius = 10
        mapView.layer.shadowPath = UIBezierPath(rect: mapView.bounds).cgPath
        mapView.layer.shouldRasterize = true
        mapView.layer.rasterizationScale = UIScreen.main.scale
        mapView.showsScale = true
        
        // Gain permissions for location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        
        // Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: true)
        }
        
        
        mapView.showsUserLocation = true
        
    }
    
}


// MARK: extension mapview delegate
extension cropView: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return DTMHeatmapRenderer(overlay: overlay)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        // not implemented
    }
}


// MARK: extension picker delegate
extension cropView: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cropManager.fileNames[row]
    }
    
}
