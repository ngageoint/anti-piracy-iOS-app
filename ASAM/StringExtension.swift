//
//  StringExtension.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 3/2/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

extension String {
    var doubleValue: Double {
       
        var value: Double;
        
        //capures some bad data from the ASAM feed where the string "null" is found in some lat/lon fields.
        if self == "null" {
            value = -999.99
        }
        else {
            value = NSNumberFormatter().numberFromString(self)!.doubleValue
        }
        
        return value
    }
    
}