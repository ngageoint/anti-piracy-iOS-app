//
//  AsamModelFacade.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 3/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class AsamModelFacade {

    var asams = [Asam]()
    
    let AND_PREDICATE = " and "
    let OR_PREDICATE = " or "
    let dateFormatter = NSDateFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()

    
    func getAsams(filterType: String)-> Array<Asam> {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Asam")
        
        fetchRequest.predicate = getFilterPredicate(filterType)
        
        let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Asam]
        asams = fetchResults!
        
        return asams
    }
    
    func getFilterPredicate(filterType: String) -> NSPredicate {
        
        var filterPredicate = NSPredicate()
        let basicFilterPredicate = getBasicFilterPredicate()
        let advancedFilterPredicate = getAdvancedFilterPredicate()
        //Filters are currently isolated
        //        if filterType == Filter.BOTH {
        //            filterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [basicFilterPredicate, advancedFilterPredicate])
        //        } else
        if filterType == Filter.BASIC_TYPE {
            filterPredicate = basicFilterPredicate
        } else if filterType == Filter.ADVANCED_TYPE {
            filterPredicate = advancedFilterPredicate
        }
        
        return filterPredicate
    }
    
    func getBasicFilterPredicate() -> NSPredicate {
        var basicFilterPredicate = getDateIntervalPredicate()
        
        if let keywordPredicate = getKeywordPredicate(Filter.Basic.KEYWORD) {
            basicFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [basicFilterPredicate, keywordPredicate])
        }
        
        if let subregionPredicate = getCurrentSubregionPredicate() {
            basicFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [basicFilterPredicate, subregionPredicate])
        }
        
        return basicFilterPredicate
    }
    
    func getAdvancedFilterPredicate() -> NSPredicate {
        var advancedFilterPredicate = getDatePredicate()
        
        if let keywordPredicate = getKeywordPredicate(Filter.Advanced.KEYWORD) {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [advancedFilterPredicate, keywordPredicate])
        }

        if let subregionPredicate = getSubregionPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [advancedFilterPredicate, subregionPredicate])
        }
        
        if let refNumPredicate = getRefNumPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [advancedFilterPredicate, refNumPredicate])
        }
        
        if let victimPredicate = getVictimPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [advancedFilterPredicate, victimPredicate])
        }

        if let aggressorPredicate = getAggressorPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [advancedFilterPredicate, aggressorPredicate])
        }
        
        return advancedFilterPredicate
    }
    
    func getDateIntervalPredicate() -> NSPredicate {
        
        var interval = DateInterval.ALL
        if let userInterval = defaults.stringForKey(Filter.Basic.DATE_INTERVAL) {
            interval = userInterval
        }
        let calendar = NSCalendar.currentCalendar()
        var today = calendar.startOfDayForDate(NSDate())
        
        //Default to 100 years, an approximate of ALL
        var intervalDate = calendar.dateByAddingUnit(.CalendarUnitYear, value: -100, toDate: today, options: nil)!
        
        switch interval {
        case DateInterval.DAYS_30:
            intervalDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: -30, toDate: today, options: nil)!
        case DateInterval.DAYS_60:
            intervalDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: -60, toDate: today, options: nil)!
        case DateInterval.DAYS_120:
            intervalDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: -120, toDate: today, options: nil)!
        case DateInterval.YEARS_1:
            intervalDate = calendar.dateByAddingUnit(.CalendarUnitYear, value: -1, toDate: today, options: nil)!
        default:
            break
        }
        
        let intervalPredicate = NSPredicate(format: "(date > %@)", intervalDate )
        
        return intervalPredicate
        
    }
    
    func getKeywordPredicate(keywordType: String) -> NSPredicate? {
        var keywordPredicate: NSPredicate? = nil
        var keyword = String()
        if let userKeyword: String = defaults.stringForKey(keywordType) {
            keyword = userKeyword
        }
        
        if !keyword.isEmpty {
            var intervalNames: [String] = []
            var intervalValues: [String] = []
            
            intervalNames.append("(aggressor CONTAINS[c] %@)")
            intervalValues.append(keyword)
            intervalNames.append("(date CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(desc CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(lat CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(latitude CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(lng CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(longitude CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(reference CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(subregion CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(victim CONTAINS[c] %@)")
            intervalValues.append(keyword)
            
            let keywordFormat = buildPredicateFormat(OR_PREDICATE, names: intervalNames)
            
            keywordPredicate = NSPredicate(format: keywordFormat, argumentArray: intervalValues)
        }
        return keywordPredicate
    }
    
    
    func getCurrentSubregionPredicate() -> NSPredicate? {
        var currentSubregionPredicate: NSPredicate? = nil
        
        
        let userDefaultCurrentEnabled = defaults.boolForKey(Filter.Basic.CURRENT_SUBREGION_ENABLED)
        
        if userDefaultCurrentEnabled {
            if let userDefaultCurrentSubregion = defaults.stringForKey(Filter.Basic.CURRENT_SUBREGION) {
                currentSubregionPredicate = NSPredicate(format: "(subregion = %@)", userDefaultCurrentSubregion )
            }
        }
        
        return currentSubregionPredicate
    }
    
    func getDatePredicate() -> NSPredicate {
        var dateNames: [String] = []
        var dateValues: [AnyObject] = []
        
        
        if let userDefaultStartDate: NSDate = defaults.objectForKey("startDate") as? NSDate {
            dateNames.append("(date > %@)")
            dateValues.append(userDefaultStartDate)
        } else {
            let calendar = NSCalendar.currentCalendar()
            var today = calendar.startOfDayForDate(NSDate())

            var approxOneYearAgo = calendar.dateByAddingUnit(.CalendarUnitYear, value: -1, toDate: today, options: nil)!
                
            dateNames.append("(date > %@)")
            dateValues.append(approxOneYearAgo)
        }
        
        if let userDefaultEndDate: NSDate = defaults.objectForKey("endDate") as? NSDate {
            dateNames.append("(date < %@)")
            dateValues.append(userDefaultEndDate)
        } else {
            dateNames.append("(date < %@)")
            dateValues.append(NSDate())
        }
        
        let datePredicateFormat = buildPredicateFormat(AND_PREDICATE, names: dateNames)
        let datePredicate = NSPredicate(format: datePredicateFormat, argumentArray: dateValues)

        return datePredicate
    }

    
    func getSubregionPredicate() -> NSPredicate? {
        var subregionPredicate: NSPredicate? = nil
        var regionNames = [String]()
        var regionValues = [AnyObject]()
        
        if let userDefaultSubRegion: Array<String> = defaults.objectForKey(Filter.Advanced.SELECTED_REGION) as? Array<String> {
            if userDefaultSubRegion.count > 0 {
                for (region) in userDefaultSubRegion {
                    regionNames.append("(subregion = %@)")
                    regionValues.append(region)
                }
                
                let subregionPredicateFormat = buildPredicateFormat(OR_PREDICATE, names: regionNames)
                subregionPredicate = NSPredicate(format: subregionPredicateFormat, argumentArray: regionValues)
            }
        }

        return subregionPredicate
    }
    
    func getRefNumPredicate() -> NSPredicate? {
        var refNumPredicate: NSPredicate? = nil
        
        if let userDefaultRefNum = defaults.stringForKey(Filter.Advanced.REFERENCE_NUM) {
            var refNumNames = String()
            var refNumValues = String()
            
            let refNum = userDefaultRefNum.componentsSeparatedByString(Filter.Advanced.REF_SEPARATER)
        
            if !refNum[0].isEmpty || !refNum[1].isEmpty {
                if !refNum[0].isEmpty && !refNum[1].isEmpty {
                    refNumNames = "(reference CONTAINS %@)"
                    refNumValues = refNum[0] + Filter.Advanced.REF_SEPARATER + refNum[1]
                } else if !refNum[0].isEmpty && refNum[1].isEmpty {
                    refNumNames = "(reference CONTAINS %@)"
                    refNumValues = refNum[0] + Filter.Advanced.REF_SEPARATER
                } else if refNum[0].isEmpty && !refNum[1].isEmpty {
                    refNumNames = "(reference CONTAINS %@)"
                    refNumValues = Filter.Advanced.REF_SEPARATER + refNum[1]
                }
                
                refNumPredicate = NSPredicate(format: refNumNames, refNumValues)
            }
        }

        return refNumPredicate
    }
    
    func getVictimPredicate() -> NSPredicate? {
        var victimPredicate: NSPredicate? = nil
        
        if let userDefaultVictim = defaults.stringForKey(Filter.Advanced.VICTIM) {
            if !userDefaultVictim.isEmpty {
                victimPredicate = NSPredicate(format: "(victim CONTAINS[c] %@)", userDefaultVictim)
            }
        }
        
        return victimPredicate
    }
    
    func getAggressorPredicate() -> NSPredicate? {
        var aggressorPredicate: NSPredicate? = nil
        
        if let userDefaultAggressor = defaults.stringForKey(Filter.Advanced.AGGRESSOR) {
            if !userDefaultAggressor.isEmpty {
                aggressorPredicate = NSPredicate(format: "(aggressor CONTAINS[c] %@)", userDefaultAggressor)
            }
        }
        
        return aggressorPredicate
    }
  
    func buildPredicateFormat(predicateType: String, names: [String]) -> String {
        var predicateFormat = String()
        if names.count > 0 {
            for index in 0..<(names.count) {
                predicateFormat += names[index]
                if index < names.count-1 {
                    predicateFormat += predicateType
                }
            }
            
        }
        
        return predicateFormat
    }
    
}