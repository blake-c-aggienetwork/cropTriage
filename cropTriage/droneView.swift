//
//  droneViewController.swift
//  cropTriage
//
//  Created by Blake Carr on 10/3/20.
//

import UIKit
import MapKit
import CoreLocation

class droneView: UIView{
    
    // MARK: IBOUTLETS
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    
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
        }
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
        
        // Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: true)
        }
        mapView.showsUserLocation = true
        
        // Add saved pins
        self.loadSavedPins()
        self.renderLines()

    }
    
}

// MARK: MKMAPVIEW DELEGATE
extension droneView: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let _identifier = "marker"
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: _identifier) as? MKMarkerAnnotationView{
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else{
            print("Adding MK MarkerAnnotationView")
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: _identifier)
            view.canShowCallout = true
            view.isDraggable = true
        }
        return view
    }
    
    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .dragging:
            self.refreshCircles()
        case .ending, .canceling:
            view.dragState = .none
            markerManager.pinMoved()
            self.refreshCircles()
            self.renderLines()
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKCircle {
                let circle = MKCircleRenderer(overlay: overlay)
                circle.strokeColor = UIColor.red
                circle.fillColor = UIColor(red: 240, green: 100, blue: 100, alpha: 0.2)
                circle.lineWidth = 1
                return circle
            }
            else if overlay is MKPolyline{
                let line = MKPolylineRenderer(overlay: overlay)
                line.strokeColor = UIColor.blue
                line.lineWidth = CGFloat(5.0)
                return line
            }
            else {
                let circle = MKCircleRenderer(overlay: overlay)
//                circle.fillColor = UIColor(red: 255, green: 1, blue: 1, alpha: 0.2)
                return circle
            }
        }
    
}
