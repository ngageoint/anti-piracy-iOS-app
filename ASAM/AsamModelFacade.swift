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
    
    var managedContext: NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    }
    
    
    func populateEntity(newAsams: NSArray) {

        if newAsams.count == 0 {
            return
        }

        //compare to whats stored
        let toAddAsams = removeDuplicates(newAsams)

        if toAddAsams.count > 0 {
            addAsams(toAddAsams)
        }
        
    }
    
    
    func clearEntity() {

        let request = NSFetchRequest(entityName: ASAM_ENTITY)
        request.returnsObjectsAsFaults = false
        
        do {
            let deleteRequest = try managedContext.executeFetchRequest(request)
            
            if deleteRequest.count > 0 {
                
                for result: AnyObject in deleteRequest {
                    managedContext.deleteObject(result as! NSManagedObject)
                }
                
                saveContext(managedContext)
            }
        } catch _ {
            //Do nothing
        }
    }
    
    
    func addAsams(addAsams: NSArray) {

        let entity = NSEntityDescription.entityForName(ASAM_ENTITY, inManagedObjectContext: managedContext)
        
        for item in addAsams {
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
            asam.setValue(Int((retrievedAsam["Subregion"]! as! String)), forKey: "subregion")
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.dateFromString(retrievedAsam["Date"] as! String)

            asam.setValue(date, forKey: "date")
            
            saveContext(managedContext)
        }
    }
    
    
    func saveContext(managedContext: NSManagedObjectContext) {
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            logError("Could not save", error: error)
        }
    }
    
    
    func logError(message: String, error: NSError?) {
        
        print(message + " \(error): \(error?.userInfo)")
    }
    
    
    func removeDuplicates(toCheckAsams: NSArray) -> [Asam] {
        let fetchRequest = NSFetchRequest(entityName: ASAM_ENTITY)
        let sortDescriptor = NSSortDescriptor(key: "reference", ascending: false)

        var toAddAsams = NSMutableArray()

        let sortedAsams = toCheckAsams.sortedArrayUsingComparator( { item1, item2 in
            let ref1 = item1["Reference"] as! String
            let ref2 = item2["Reference"] as! String
            if  ref1 < ref2 {
                return NSComparisonResult.OrderedDescending
            } else if ref1 > ref2 {
                return NSComparisonResult.OrderedAscending
            } else {
                return NSComparisonResult.OrderedSame
            }
        })
        
        var refNumToCheck = [String]()
        for item in sortedAsams {
            let refNum = item as! NSDictionary
            if let ref = refNum["Reference"] as? String {
                refNumToCheck.append(ref)
            }
        }
        
        fetchRequest.predicate = NSPredicate(format: "(reference IN %@)", refNumToCheck)
        fetchRequest.sortDescriptors = [sortDescriptor]

        //var error: NSError?
        var fetchResults = [Asam]()
        do {
            try fetchResults = (managedContext.executeFetchRequest(fetchRequest) as? [Asam])!
        } catch _ {
            //No results returned.
        }
        print("Number of results: \(fetchResults.count)")
        
        if fetchResults.count > 0 {
            var iterator = 0
            if fetchResults.count <= sortedAsams.count {
            for item in sortedAsams {
                let anAsam = item as! NSDictionary
                if (iterator < fetchResults.count) &&
                    (anAsam["Reference"] as! String == fetchResults[iterator].reference) {
                        iterator++
                } else {
                    toAddAsams.addObject(anAsam)
                }
            }
            } else {
                print("Error: Duplicates in the database, resetting values")
                //Duplicates should not be allowed in the database, if any are found it was the result
                //of an error. Clear out the database and reload all ASAMs
                clearEntity()
                defaults.setValue(false, forKey: AppSettings.FIRST_LAUNCH)
                //TODO: App will need to get restarted to load ASAMs
                //Might want to reload Asams here instead
            }
            
        } else {
            toAddAsams = toCheckAsams as! NSMutableArray
        }
        
        return toAddAsams as NSArray as! [Asam]
    }
    
    
    func getLatestAsamDate() -> NSDate {
        var latestDate: NSDate!
        let fetchRequest = NSFetchRequest(entityName: ASAM_ENTITY)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor]
        let calendar = NSCalendar.currentCalendar()
        
        let error: NSError? = nil
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Asam]
            
            if let results = fetchResults {
                if results.count > 0 {
                    var latestResults = fetchResults!
                    let latestAsam = latestResults[0]
                    let asamDate = calendar.startOfDayForDate(latestAsam.date)
                    //Set back 60 days to grab any Asams input late
                    latestDate = calendar.dateByAddingUnit(.Day, value: -60, toDate: asamDate, options: [])!
                } else {
                    //Default to 1 year if no Asam found
                    let asamDate = calendar.startOfDayForDate(NSDate())
                    latestDate = calendar.dateByAddingUnit(.Year, value: -1, toDate: asamDate, options: [])!
                }
            } else {
                logError("Could not fetch latest ASAM", error: error)
            }
        } catch _ {
            //No results returned.
        }
        return latestDate
    }
    
    
    func getAsams(filterType: String)-> Array<Asam> {

        let fetchRequest = NSFetchRequest(entityName: ASAM_ENTITY)
        fetchRequest.predicate = getFilterPredicate(filterType)
        
        let error: NSError? = nil
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Asam]
            
            if let _ = fetchResults {
                filteredAsams = fetchResults!
            } else {
                logError("Could not fetch filtered ASAMs", error: error)
            }
            
        } catch _ {
            //No results returned.
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
        let today = calendar.startOfDayForDate(NSDate())
        
        //Default to 100 years, an approximate of ALL
        var intervalDate = calendar.dateByAddingUnit(.Year, value: -100, toDate: today, options: [])!
        
        switch interval {
        case DateInterval.DAYS_30:
            intervalDate = calendar.dateByAddingUnit(.Day, value: -30, toDate: today, options: [])!
        case DateInterval.DAYS_60:
            intervalDate = calendar.dateByAddingUnit(.Day, value: -60, toDate: today, options: [])!
        case DateInterval.DAYS_120:
            intervalDate = calendar.dateByAddingUnit(.Day, value: -120, toDate: today, options: [])!
        case DateInterval.YEARS_1:
            intervalDate = calendar.dateByAddingUnit(.Year, value: -1, toDate: today, options: [])!
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
            let today = calendar.startOfDayForDate(NSDate())

            let approxOneYearAgo = calendar.dateByAddingUnit(.Year, value: -1, toDate: today, options: [])!
                
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