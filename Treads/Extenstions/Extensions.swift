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
