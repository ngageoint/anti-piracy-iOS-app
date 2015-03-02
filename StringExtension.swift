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
        return NSNumberFormatter().numberFromString(self)!.doubleValue
    }
}