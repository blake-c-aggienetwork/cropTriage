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
import CSV

class cropView: UIView {
    
    // MARK: data members
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    let defaults = UserDefaults()
    var mapTypeIndex: Int = 0
    
    // IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var controlView: UIView!
    
    
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
        
        controlView.layer.cornerRadius = 10 // edit control view properties
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
    
    
}
