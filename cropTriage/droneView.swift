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
    
    // MARK: MARKER DATA
    var pinArr: [MKAnnotation]
    var circleArr: [MKCircle]
    
    
    // MARK: IBACTIONS
    @IBAction func addMarker(_ sender: Any) {
        let centerCoordinate = mapView.centerCoordinate
        
        print("Attemping to create marker at")
        print(centerCoordinate)
        createAnnotation(title: "", coordinates: centerCoordinate)
    }
    
    
    // Create Map Marker given location
    func createAnnotation(title: String, coordinates: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        let circle = MKCircle(center: coordinates, radius: 25)
        mapView.addOverlay(circle)
        
        pinArr.append(annotation)
        circleArr.append(circle)
    }
    
    func updatePinlist(){
        let end = circleArr.count-1
        for i in 0...end{
            mapView.removeOverlay(circleArr[i])
            let circle = MKCircle(center: pinArr[i].coordinate, radius: 25)
            circleArr[i] = circle
            mapView.addOverlay(circleArr[i])
        }
    }
    
    // Required Inits
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
    override init(frame: CGRect){
        pinArr = []
        circleArr = []
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        pinArr = []
        circleArr = []
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
        mapView.mapType = MKMapType.standard
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
        
        pinArr = []
        circleArr = []
        
        
    }
    
}

// MKampView Deleget extension
extension droneView: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        
        let _identifier = "marker"
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: _identifier) as? MKMarkerAnnotationView{
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else{
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
            self.updatePinlist()
        case .ending, .canceling:
            view.dragState = .none
            self.updatePinlist()
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
            } else {
                let circle = MKCircleRenderer(overlay: overlay)
//                circle.fillColor = UIColor(red: 255, green: 1, blue: 1, alpha: 0.2)
                return circle
            }
        }
    
}
