//
//  droneViewMapDelegate.swift
//  cropTriage
//
//  Created by Blake Carr on 10/25/20.
//

import Foundation
import MapKit
import CoreLocation


// MARK: MKMAPVIEW DELEGATE
extension droneView: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
                // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                return nil
            }
        
        let _identifier = "marker"
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: _identifier) as? MKMarkerAnnotationView{
                print("adding annotation view")
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
