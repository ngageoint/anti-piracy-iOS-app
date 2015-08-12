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
    let defaults = NSUserDefaults.standardUserDefaults()

    
    func getAsams(filterType: Int = Filter.BOTH)-> Array<Asam> {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Asam")
        
        fetchRequest.predicate = getFilterPredicate(filterType: filterType)
        
        let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Asam]
        asams = fetchResults!
        
        return asams
    }
    
    
    func getFilterPredicate(filterType: Int = Filter.BOTH) -> NSPredicate {
        
        var returnFilterPredicate
        let basicFilterPredicate = getBasicFilterPredicate()
        let advancedFilterPredicate = getAdvancedFilterPredicate()
        
        if filterType == Filter.BOTH {
            returnFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [basicFilterPredicate, advancedFilterPredicate])
        } else if filterType == Filter.BASIC {
            returnFilterPredicate = basicFilterPredicate
        } else if filterType == Filter.ADVANCED {
            returnFilterPredicate = advancedFilterPredicate
        }
        
        return returnFilterPredicate
    }
    
    func getBasicFilterPredicate() -> NSPredicate {
        var filterPredicate = getDateIntervalPredicate()
        
        if let keywordPredicate = getKeywordPredicate() {
            filterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [filterPredicate, keywordPredicate])
        }
        
        if let subregionPredicate = getSubregionPredicate() {
            filterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [filterPredicate, subregionPredicate])
        }
        
        return filterPredicate
    }
    
    
    func getAdvancedFilterPredicate() -> NSPredicate {
        var filterPredicate = getDatePredicate()

        if let subregionPredicate = getSubregionPredicate() {
            filterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [filterPredicate, subregionPredicate])
        }
       
        return filterPredicate
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
        
        //build predicate string
        let datePredicateFormat = buildPredicateFormat(AND_PREDICATE, names: dateNames)
        
        var datePredicate = NSPredicate(format: datePredicateFormat, argumentArray: dateValues)

        return datePredicate
    }

    
    func getSubregionPredicate() -> NSPredicate? {
        var subregionPredicate: NSPredicate? = nil
        var regionNames = [String]()
        var regionValues = [AnyObject]()
        
        if let userDefaultSubRegion: Array<String> = defaults.objectForKey(Filter.Advanced.SELECTED_REGION) as? Array<String> {
            if userDefaultSubRegion.count > 0 {
                for (region) in userDefaultSubRegion {
                    regionNames.append("(subregion == %i)")
                    regionValues.append(region.toInt()!)
                }
                
                let subregionPredicateFormat = buildPredicateFormat(OR_PREDICATE, names: regionNames)
                subregionPredicate = NSPredicate(format: subregionPredicateFormat, argumentArray: regionValues)
            }
        }

        return subregionPredicate
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