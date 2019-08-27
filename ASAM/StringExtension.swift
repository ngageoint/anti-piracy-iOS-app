//
//  StringExtension.swift
//  anti-piracy-iOS-app
//


import Foundation

extension String {
    var getDouble: Double {
       
        var value: Double;
        
        //capures some bad data from the ASAM feed where the string "null" is found in some lat/lon fields.
        if self == "null" {
            value = -999.99
        }
        else {
            value = NumberFormatter().number(from: self)!.doubleValue
        }
        
        return value
    }
    
}
