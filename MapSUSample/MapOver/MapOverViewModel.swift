//
//  ContentViewModel.swift
//  MapSUSample
//

import Foundation
import MapKit

final class MapOverViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion = .init()
    @Published var searchResults = [MKMapItem]()
    
    @Published var selectItem: MKMapItem?
    @Published var selectPin: MKPointAnnotation?
    
    func searchForPOIs(at coordinate: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        request.naturalLanguageQuery = "cafe"
        
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let response = response else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self?.searchResults = response.mapItems
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
