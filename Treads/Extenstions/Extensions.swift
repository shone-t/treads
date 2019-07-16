//
//  Extensions.swift
//  Treads
//
//  Created by MacBook Pro on 7/16/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation

extension Double {
    
    func metersToMiles(place: Int) -> Double {
        let divisor = pow(10.0, Double(place))
        return ((self / 1609.34) * divisor).rounded() / divisor
    }
    
}

extension Int {
    func formatTimeDurationToString() -> String{
        let durationHours = self / 3600
        let durationMinutes = (self % 3600) / 60
        let durationSecond = (self % 3600) % 60
        
        if durationSecond < 0 {
            return "00:00:00"
        } else {
            if durationHours == 0 {
                return String(format: "%02d:%02d", durationMinutes, durationSecond )
            } else {
                return String(format: "%02d:%02d:%02d", durationHours, durationMinutes, durationSecond)
            }
        }
    }
}
