//
//  Status.swift
//  Chat
//
//  Created by David Kababyan on 07/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

enum Status: String, CaseIterable {
    
    case Available = "Available"
    case Busy = "Busy"
    case AtSchool = "At School"
    case AtTheMovies = "At The Movies"
    case AtWork = "At Work"
    case BatteryAboutToDie = "Battery About To Die"
    case CantTalk = "Can't Talk, WhatsApp Only"
    case InAMeeting = "In a Meeting"
    case AtTheGym = "At The Gym"
    case Sleeping = "Sleeping"
    case UrgentCallsOnly = "Urgent Calls Only"
    
}
