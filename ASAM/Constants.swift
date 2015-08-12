//
//  Constants.swift
//  ASAM
//
//  Created by Chris Wasko on 8/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

struct Filter {
    struct Advanced {
        static let START_DATE = "startDate"
        static let END_DATE = "endDate"
        static let KEYWORD = "keyword"
        static let SELECTED_REGION = "selectedRegions"
        static let REFERENCE_NUM = "referenceNum"
        static let VICTIM = "victim"
        static let AGGRESSOR = "aggressor"
        static let REF_SEPARATER = "-"
    }
    struct Basic {
        static let DATE_INTERVAL = "dateInterval"
        static let KEYWORD = "keyword"
        static let CURRENT_SUBREGION = "currentSubregion"
    }
    static let BOTH = 3
    static let ADVANCED = 2
    static let BASIC = 1
}

struct DateInterval {
    static let DAYS_30 = "Last 30 Days"
    static let DAYS_60 = "Last 60 Days"
    static let DAYS_120 = "Last 120 Days"
    static let YEARS_1 = "Last 1 Year"
    static let DEFAULT = 3
}