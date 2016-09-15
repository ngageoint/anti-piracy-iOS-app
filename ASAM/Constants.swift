//
//  Constants.swift
//  ASAM
//


import Foundation

struct Filter {
    struct Advanced {
        static let START_DATE = "startDate"
        static let END_DATE = "endDate"
        static let KEYWORD = "advancedKeyword"
        static let SELECTED_REGION = "selectedRegions"
        static let REFERENCE_NUM = "referenceNum"
        static let VICTIM = "victim"
        static let AGGRESSOR = "aggressor"
        static let REF_SEPARATER = "-"
    }
    struct Basic {
        static let DATE_INTERVAL = "dateInterval"
        static let KEYWORD = "basicKeyword"
        static let CURRENT_SUBREGION_ENABLED = "currentSubregionEnabled"
        static let CURRENT_SUBREGION = "currentSubregion"
        static let DEFAULT_SUBREGION = "57" //Subregion of coord (0.0, 0.0)
    }
    static let FILTER_TYPE = "filterType"
    static let ADVANCED_TYPE = "advancedFilter"
    static let BASIC_TYPE = "basicFilter"
}

struct Date {
    static let ALL = "All"
    static let DAYS_30 = "Last 30 Days"
    static let DAYS_60 = "Last 60 Days"
    static let DAYS_120 = "Last 120 Days"
    static let YEARS_1 = "Last 1 Year"
    static let DEFAULT = 0
    static var FORMAT:String = "MM/dd/yyyy"
}

struct MapView {
    static let MAP_TYPE = "mapType"
    static let LATITUDE = "mapViewLatitude"
    static let LONGITUDE = "mapViewLongitude"
    static let LAT_DELTA = "mapViewLatitudeDelta"
    static let LON_DELTA = "mapViewLongitudeDelta"
}

struct AppSettings {
    static let FIRST_LAUNCH = "firstApplicationLaunch"
}
