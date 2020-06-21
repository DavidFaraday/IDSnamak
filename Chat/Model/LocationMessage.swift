//
//  LocationMessage.swift
//  Chat
//
//  Created by David Kababyan on 20/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {

        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
