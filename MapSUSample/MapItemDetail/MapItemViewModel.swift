//
//  MapItemViewModel.swift
//  MapSUSample
//

import Foundation
import SwiftUI
import MapKit

final class MapItemViewModel: ObservableObject {
    enum ViewEvent {
        case pop
    }
    
    let item: MKMapItem
    
    @Published var viewEvent: ViewEvent?
    
    init(_ item: MKMapItem) {
        self.item = item
    }
}
