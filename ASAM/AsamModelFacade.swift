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

    var filteredAsams = [Asam]()
    
    let AND_PREDICATE = " and "
    let OR_PREDICATE = " or "
    let ASAM_ENTITY = "Asam"
    let dateFormatter = NSDateFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    var allAsams: NSArray!
    
    var managedContext: NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    }
    
    func populateEntity(data: NSArray) {
        allAsams = data
        
        //compare to whats stored
        //add any new ones
        
        //doing clear and setup to bring in all asams for development
        clearEntity()
        setupEntity()
    }
    
    
    func clearEntity() {

        var request = NSFetchRequest(entityName: ASAM_ENTITY)
        request.returnsObjectsAsFaults = false

        var deleteRequest = managedContext.executeFetchRequest(request, error: nil)!
        
        if deleteRequest.count > 0 {
            
            for result: AnyObject in deleteRequest {
                managedContext.deleteObject(result as! NSManagedObject)
            }
            
            saveContext(managedContext)
        }
    }
    
    
    func setupEntity() {

        let entity = NSEntityDescription.entityForName(ASAM_ENTITY, inManagedObjectContext: managedContext)
        
        for item in allAsams {
            let retrievedAsam = item as! NSDictionary
            let asam = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            
            asam.setValue(retrievedAsam["Reference"]!, forKey: "reference")
            asam.setValue(retrievedAsam["Aggressor"]!, forKey: "aggressor")
            asam.setValue(retrievedAsam["Victim"]!, forKey: "victim")
            asam.setValue(retrievedAsam["Description"]!, forKey: "desc")
            asam.setValue(retrievedAsam["Latitude"]!, forKey: "latitude")
            asam.setValue(retrievedAsam["Longitude"]!, forKey: "longitude")
            asam.setValue((retrievedAsam["lat"]! as! String).doubleValue, forKey: "lat")
            asam.setValue((retrievedAsam["lng"]! as! String).doubleValue, forKey: "lng")
            asam.setValue((retrievedAsam["Subregion"]! as! String).toInt(), forKey: "subregion")
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            var date = formatter.dateFromString(retrievedAsam["Date"] as! String)

            asam.setValue(date, forKey: "date")
            
            saveContext(managedContext)
        }
    }
    
    
    func saveContext(managedContext: NSManagedObjectContext) {
        
        var error: NSError?
        if !managedContext.save(&error) {
            logError("Could not save", error: error)
        }
    }
    
    
    func logError(message: String, error: NSError?) {
        
        println(message + " \(error): \(error?.userInfo)")
    }
    
    
    func getAsams(filterType: String)-> Array<Asam> {

        let fetchRequest = NSFetchRequest(entityName: ASAM_ENTITY)
        fetchRequest.predicate = getFilterPredicate(filterType)
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [Asam]
        
        if let results = fetchResults {
            filteredAsams = fetchResults!
        } else {
            logError("Could not fetch", error: error)
        }
        
        return filteredAsams
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
        
        
        if let userDefaultStartDate: NSDate = defaults.objectForKey(Filter.Advanced.START_DATE) as? NSDate {
            dateNames.append("(date > %@)")
            dateValues.append(userDefaultStartDate)
        } else {
            let calendar = NSCalendar.currentCalendar()
            var today = calendar.startOfDayForDate(NSDate())

            var approxOneYearAgo = calendar.dateByAddingUnit(.CalendarUnitYear, value: -1, toDate: today, options: nil)!
                
            dateNames.append("(date > %@)")
            dateValues.append(approxOneYearAgo)
        }
        
        if let userDefaultEndDate: NSDate = defaults.objectForKey(Filter.Advanced.END_DATE) as? NSDate {
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