//
//  MapOverViewController.swift
//  MapSUSample
//

import Foundation
import UIKit
import SwiftUI
import TinyConstraints
import MapKit
import Combine

final class MapOverViewController: UIViewController {
    private enum Const {
        static let contentHeight: CGFloat = 300
    }
    
    private let viewModel = MapOverViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var centerMarkerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        observe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MapViewController.shared?.mapView.isUserInteractionEnabled = true
    }
    
    deinit {
        MapViewController.shared?.mapView.delegate = nil
        centerMarkerView?.removeFromSuperview()
    }
    
    private func observe() {
        viewModel.$selectItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedItem in
                guard let self = self, let selectedItem = selectedItem else { return }
                let detailVC = MapItemViewController(selectedItem)
                detailVC.view.backgroundColor = .clear
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.updateMapAnnotations(results)
            }
            .store(in: &cancellables)
    }
    
    private func updateMapAnnotations(_ results: [MKMapItem]) {
        guard let mapView = MapViewController.shared?.mapView else { return }
        mapView.removeAnnotations(mapView.annotations)

        for item in results {
            let annotation = MKPointAnnotation()
            annotation.title = item.name ?? "cafe"
            annotation.subtitle = item.placemark.title
            annotation.coordinate = item.placemark.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    private func addCenterMarker(_ mapView: MKMapView) {
        let markerSize: CGFloat = 20.0
        let markerView = UIView()
        markerView.frame = CGRect(x: 0, y: 0, width: markerSize, height: markerSize)
        markerView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        markerView.layer.cornerRadius = markerSize / 2
        markerView.layer.borderWidth = 2.0
        markerView.layer.borderColor = UIColor.white.cgColor
        
        let centerPoint = CGPoint(
            x: mapView.bounds.midX,
            y: (mapView.layoutMargins.top + mapView.bounds.height - mapView.layoutMargins.bottom) / 2
        )
        markerView.center = centerPoint
        mapView.addSubview(markerView)
        centerMarkerView = markerView
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        let overView = MapTouchView(frame: .zero)
        view.addSubview(overView)
        overView.edgesToSuperview()
        
        let hostingController = MapHostingViewController(rootView: MapOverView().environmentObject(viewModel))
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.backgroundColor = .clear
        hostingController.view.leadingToSuperview()
        hostingController.view.trailingToSuperview()
        hostingController.view.bottomToSuperview(usingSafeArea: false)
        hostingController.view.height(Const.contentHeight)
        
        if let mapView = MapViewController.shared?.mapView {
            mapView.layoutMargins.bottom = Const.contentHeight
            mapView.delegate = self
            
            addCenterMarker(mapView)
            updateRegion(mapView.region)
        }
    }
    
    func updateRegion(_ region: MKCoordinateRegion) {
        viewModel.region = region
        viewModel.searchForPOIs(at: region.center)
    }
}


extension MapOverViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print("mapViewDidChangeVisibleRegion")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateRegion(mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            viewModel.selectPin = annotation
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomPin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let button = UIButton(type: .infoLight)
            annotationView?.rightCalloutAccessoryView = button
        }
        
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let pointAnnotation = view.annotation as? MKPointAnnotation else {
            return
        }
        
        viewModel.selectItem = viewModel.searchResults.first(where: { $0.placemark.coordinate == pointAnnotation.coordinate })
    }
}

