//
//  MapViewViewController.swift
//  Chat
//
//  Created by David Kababyan on 21/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//all done
class MapViewViewController: UIViewController {

    //MARK: - Vars
    var location: CLLocation?
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTitle()
        configureMapView()
        configureLeftBarButton()
    }
    
    //MARK: - Configurations
    private func configureTitle() {
        self.title = "Map View"
    }
    
    private func configureMapView() {
        
        mapView = MKMapView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: nil, coordinate: location!.coordinate))
        }
        
        view.addSubview(mapView)
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]

    }

    //MARK: - Actions
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }

}


