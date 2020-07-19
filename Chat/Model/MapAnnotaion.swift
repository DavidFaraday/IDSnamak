//
//  MapAnnotaion.swift
//  Chat
//
//  Created by David Kababyan on 21/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
     let title: String?
     let coordinate: CLLocationCoordinate2D
     
     init(title: String?, coordinate: CLLocationCoordinate2D) {
       self.title = title
       self.coordinate = coordinate
     }
}
