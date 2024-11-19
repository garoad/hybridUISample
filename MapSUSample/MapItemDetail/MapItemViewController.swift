//
//  MapItemViewController.swift
//  MapSUSample
//

import Foundation
import SwiftUI
import MapKit
import Combine

class MapItemViewController: UIViewController {
    private let viewModel: MapItemViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(_ item: MKMapItem) {
        self.viewModel = MapItemViewModel(item)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupSUView()
        if let mapView = MapViewController.shared?.mapView {
            mapView.centerCoordinate = viewModel.item.placemark.coordinate
        }
        
        viewModel.$viewEvent.sink { [weak self] viewEvent in
            guard let self else { return }
            
            if let viewEvent, viewEvent == .pop {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupSUView() {
        view.backgroundColor = .clear
        let hostingController = MapHostingViewController(rootView: MapItemView().environmentObject(viewModel))
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.edgesToSuperview()
    }
}
