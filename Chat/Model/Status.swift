//
//  Status.swift
//  Chat
//
//  Created by David Kababyan on 07/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

enum Status: String {
    
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
    
    static var array: [Status] {
        var a: [Status] = []
        
        switch Status.Available {
        case .Available:
            a.append(.Available); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .AtSchool:
            a.append(.AtSchool); fallthrough
        case .AtTheMovies:
            a.append(.AtTheMovies); fallthrough
        case .AtWork:
            a.append(.AtWork); fallthrough
        case .BatteryAboutToDie:
            a.append(.BatteryAboutToDie); fallthrough
        case .CantTalk:
            a.append(.CantTalk); fallthrough
        case .InAMeeting:
            a.append(.InAMeeting); fallthrough
        case .AtTheGym:
            a.append(.AtTheGym); fallthrough
        case .Sleeping:
            a.append(.Sleeping); fallthrough
        case .UrgentCallsOnly:
            a.append(.UrgentCallsOnly);
        return a
        }
    }
}
