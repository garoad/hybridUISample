//
//  ViewController.swift
//  MapSUSample
//

import UIKit
import MapKit
import SwiftUI
import TinyConstraints

class MapViewController: UIViewController, MKMapViewDelegate {
    static var shared: MapViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if MapViewController.shared == nil {
            MapViewController.shared = self
        }
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    var mapView: MKMapView!
    var mainUINavigationController: UINavigationController = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        mapView.edgesToSuperview()
        mapView.layoutMargins.top = view.safeAreaInsets.top
        
        let initialLocation = CLLocation(latitude: 37.49795, longitude: 127.027637) // 강남역
        mapView.centerToLocation(initialLocation)
        setupView()
    }
    
    private func setupView() {
        let vc = MapOverViewController()
        mainUINavigationController = UINavigationController(rootViewController: vc)
        self.addChild(mainUINavigationController)
        view.addSubview(mainUINavigationController.view)
        mainUINavigationController.view.edgesToSuperview()
    }
}


private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

final class MapTouchView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            print(point)
            
            guard let mapContainView = MapViewController.shared?.mapView else {
                return hitView
            }
            
            let pointOfMapContaingView = convert(point, to: mapContainView)
            
            return mapContainView.hitTest(pointOfMapContaingView, with: event)
        }
        return hitView
    }
}

