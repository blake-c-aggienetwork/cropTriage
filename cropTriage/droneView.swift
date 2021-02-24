//
//  droneViewController.swift
//  cropTriage
//
//  Created by Blake Carr on 10/3/20.
//

import UIKit
import MapKit
import CoreLocation

class droneView: UIView, UIGestureRecognizerDelegate{
    
    // MARK: IBOUTLETS
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var controlView: UIView!
    
    // MARK: DATA management
    let defaults = UserDefaults.standard
    var mapTypeIndex: Int = 0
    var line = MKPolyline()
    let markerManager = MarkerDataManger()
    
    // MARK: IBACTIONS
    @IBAction func addMarker(_ sender: Any) {
        let centerCoordinate = mapView.centerCoordinate
        
        print("Attemping to create marker at")
        print(centerCoordinate)
        markerManager.addPoint(lat: centerCoordinate.latitude, long: centerCoordinate.longitude, isWayPoint: false)
        mapView.addAnnotation(markerManager.getLastPin())
        mapView.addOverlay(markerManager.getLastCircle())
        
        self.renderLines()
    }
    @IBAction func removeAllMarkers(_ sender: Any) {
        if markerManager.getPinCnt() > 0{
            for i in 0...markerManager.getPinCnt()-1{
                mapView.removeAnnotation(markerManager.getPin(at: i))
                mapView.removeOverlay(markerManager.getCircle(at: i))
            }
        }
        markerManager.deleteAllPins()
        self.renderLines()
        self.updateTime()
    }
    
    
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
    
    // gesture for placing pins

    
    func renderLines(){
        for overlay in mapView.overlays {
            if overlay is MKPolyline{
                print("Removing line")
                mapView.removeOverlay(overlay)
            }
        }
        
        if markerManager.getPinCnt() > 1{
            print("refreshing line")
            var coordArr = Array<CLLocationCoordinate2D>()
            for pin in markerManager.pinArr{
                coordArr.append(pin.coordinate)
            }
            line = MKPolyline(coordinates: coordArr, count: coordArr.count)
            mapView.addOverlay(line)
            updateTime(coordArr: coordArr)
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
//        print("double tapped")
//        mapView.isZoomEnabled = false
//        print("temp disabled zoom")
//        
//        let location = sender.location(in: mapView)
//        let coord = mapView.convert(location, toCoordinateFrom: mapView)
//        
//        print("Attemping to create marker from double tap at")
//        
//        print(coord)
//        markerManager.addPoint(lat: coord.latitude, long: coord.longitude, isWayPoint: false)
//        mapView.addAnnotation(markerManager.getLastPin())
//        mapView.addOverlay(markerManager.getLastCircle())
//        
//        self.renderLines()
//        
//        mapView.isZoomEnabled = true
        
    }
    @IBAction func printLocationsToConsole(_ sender: Any) {
        if markerManager.getPinCnt() == 0{
            return
        }
        else{
            print("Coordinates selected:")
            for pin in markerManager.pinArr{
                print(pin.coordinate)
            }
        }
    }
    
    
    func updateTime(){
        print("updating time to: 00:00")
        timeLabel.text = "00:00"
    }
    
    func updateTime(coordArr: Array<CLLocationCoordinate2D>){
        print("Updating Time")
        var pathDistance: CLLocationDistance = 0.0
        for i in 0...coordArr.endIndex-2{
            let coord1 = CLLocation(latitude: coordArr[i].latitude, longitude: coordArr[i].longitude)
            let coord2 = CLLocation(latitude: coordArr[i+1].latitude, longitude: coordArr[i+1].longitude)
            
            pathDistance = pathDistance + coord1.distance(from: coord2)
        }
//        print("Total Drone Path Distance: " + String(pathDistance))
        let droneSpeedInMetersPerSecond = 25.0/2
        let timeInSeconds: Double = pathDistance/droneSpeedInMetersPerSecond + 360.0*Double(coordArr.count)
//        print("Estimated Time in Seconds: " + String(timeInSeconds))
        let hoursCnt = Int(floor(timeInSeconds/3600))
//        print(hoursCnt)
        let minutesCnt = Int(ceil((timeInSeconds/3600.0 - Double(hoursCnt))*60.0))
//        print(minutesCnt)
        
        let updatedString = String(format: "%02d:", hoursCnt) + String(format: "%02d", minutesCnt)
        
        print("updateting time to: " + updatedString)
        timeLabel.text = updatedString
        
    }
    
    func refreshCircles(){
        print("Refreshing circles")
        // refresh circle locations
        if markerManager.getPinCnt() > 0{
            for i in 0...markerManager.getPinCnt()-1{
                mapView.removeOverlay(markerManager.getCircle(at: i))
                markerManager.overwriteCircle(at: i, circle: MKCircle(center: markerManager.getPin(at: i).coordinate, radius: 25))
                mapView.addOverlay(markerManager.getCircle(at: i))
            }
        }
        
    }
    
    func loadSavedPins(){
        if markerManager.getPinCnt() > 0{
            for i in 0...markerManager.getPinCnt()-1{
                mapView.addAnnotation(markerManager.getPin(at: i))
                mapView.addOverlay(markerManager.getCircle(at: i))
            }
        }
    }
    
    // Required Inits
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
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
        Bundle.main.loadNibNamed("droneView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        print("Loaded droneView.XIB")
        
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
        
        // Add saved pins
        self.loadSavedPins()
        self.renderLines()
        
        // Edit control view properties
        controlView.layer.cornerRadius = 10
        
        
        // zoom to last marker if one exists
        if markerManager.getPinCnt() > 0{
            let lastPin = markerManager.getLastPin()
            let viewRegion = MKCoordinateRegion(center: lastPin.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: true)
        }
        else{
            // Zoom to user location
            if let userLocation = locationManager.location?.coordinate {
                let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(viewRegion, animated: true)
            }
            
        }
        
        
        mapView.showsUserLocation = true
        

    }
    
}
