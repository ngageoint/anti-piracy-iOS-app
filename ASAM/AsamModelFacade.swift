//
//  AsamModelFacade.swift
//  anti-piracy-iOS-app
//


import Foundation
import CoreData
import UIKit


class AsamModelFacade {

    var filteredAsams = [Asam]()
    
    let AND_PREDICATE = " and "
    let OR_PREDICATE = " or "
    let ASAM_ENTITY = "Asam"
    let dateFormatter = DateFormatter()
    let defaults = UserDefaults.standard
    
    var managedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
    }
    
    
    func populateEntity(_ newAsams: [[String:Any]]) {

        if newAsams.count == 0 {
            return
        }

        //compare to whats stored
        let toAddAsams = removeDuplicates(newAsams)

        if toAddAsams.count > 0 {
            addAsams(toAddAsams as NSArray)
        }
        
    }
    
    
    func clearEntity() {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ASAM_ENTITY)
        request.returnsObjectsAsFaults = false
        
        do {
            let deleteRequest = try managedContext.fetch(request)
            
            if deleteRequest.count > 0 {
                
                for result: Any in deleteRequest {
                    managedContext.delete(result as! NSManagedObject)
                }
                
                saveContext(managedContext)
            }
        } catch _ {
            //Do nothing
        }
    }
    
    
    func addAsams(_ addAsams: NSArray) {

        let entity = NSEntityDescription.entity(forEntityName: ASAM_ENTITY, in: managedContext)
        
        for item in addAsams {
            let retrievedAsam = item as! NSDictionary
            let asam = NSManagedObject(entity: entity!, insertInto:managedContext)
            
            asam.setValue(retrievedAsam["Reference"]!, forKey: "reference")
            asam.setValue(retrievedAsam["Aggressor"]!, forKey: "aggressor")
            asam.setValue(retrievedAsam["Victim"]!, forKey: "victim")
            asam.setValue(retrievedAsam["Description"]!, forKey: "desc")
            asam.setValue(retrievedAsam["Latitude"]!, forKey: "latitude")
            asam.setValue(retrievedAsam["Longitude"]!, forKey: "longitude")
            asam.setValue((retrievedAsam["lat"]! as! String).getDouble, forKey: "lat")
            asam.setValue((retrievedAsam["lng"]! as! String).getDouble, forKey: "lng")
            asam.setValue(Int((retrievedAsam["Subregion"]! as! String)), forKey: "subregion")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.date(from: retrievedAsam["Date"] as! String)

            asam.setValue(date, forKey: "date")
            
            saveContext(managedContext)
        }
    }
    
    
    func saveContext(_ managedContext: NSManagedObjectContext) {
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            logError("Could not save", error: error)
        }
    }
    
    
    func logError(_ message: String, error: NSError?) {
        
        print(message + " \(error): \(error?.userInfo)")
    }
    
    
    func removeDuplicates(_ toCheckAsams: [[String:Any]]) -> [Asam] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ASAM_ENTITY)
        let sortDescriptor = NSSortDescriptor(key: "reference", ascending: false)

        var toAddAsams = NSMutableArray()
        
        let sortedAsams = toCheckAsams.sorted { (item1, item2) -> Bool in
            let ref1 = item1["Reference"] as! String
            let ref2 = item2["Reference"] as! String
            
            if  ref1 < ref2 {
                return true
            } else {
                return false
            }
        }
        
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
            try fetchResults = (managedContext.fetch(fetchRequest) as? [Asam])!
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
                        iterator = iterator + 1
                } else {
                    toAddAsams.add(anAsam)
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
    
    
    func getLatestAsamDate() -> Foundation.Date {
        var latestDate: Foundation.Date!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ASAM_ENTITY)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor]
        let calendar = Calendar.current
        
        let error: NSError? = nil
        do {
            let fetchResults = try managedContext.fetch(fetchRequest) as? [Asam]
            
            if let results = fetchResults {
                if results.count > 0 {
                    var latestResults = fetchResults!
                    let latestAsam = latestResults[0]
                    let asamDate = calendar.startOfDay(for: latestAsam.date)
                    //Set back 60 days to grab any Asams input late
                    latestDate = (calendar as NSCalendar).date(byAdding: .day, value: -60, to: asamDate, options: [])!
                } else {
                    //Default to 1 year if no Asam found
                    let asamDate = calendar.startOfDay(for: Foundation.Date())
                    latestDate = (calendar as NSCalendar).date(byAdding: .year, value: -1, to: asamDate, options: [])!
                }
            } else {
                logError("Could not fetch latest ASAM", error: error)
            }
        } catch _ {
            //No results returned.
        }
        return latestDate
    }
    
    
    func getAsams(_ filterType: String)-> Array<Asam> {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ASAM_ENTITY)
        fetchRequest.predicate = getFilterPredicate(filterType)
        
        let error: NSError? = nil
        do {
            let fetchResults = try managedContext.fetch(fetchRequest) as? [Asam]
            
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
    
    
    func getFilterPredicate(_ filterType: String) -> NSPredicate {
        
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
            basicFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [basicFilterPredicate, keywordPredicate])
        }
        
        if let subregionPredicate = getCurrentSubregionPredicate() {
            basicFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [basicFilterPredicate, subregionPredicate])
        }
        
        return basicFilterPredicate
    }
    
    
    func getAdvancedFilterPredicate() -> NSPredicate {
        var advancedFilterPredicate = getDatePredicate()
        
        if let keywordPredicate = getKeywordPredicate(Filter.Advanced.KEYWORD) {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [advancedFilterPredicate, keywordPredicate])
        }

        if let subregionPredicate = getSubregionPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [advancedFilterPredicate, subregionPredicate])
        }
        
        if let refNumPredicate = getRefNumPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [advancedFilterPredicate, refNumPredicate])
        }
        
        if let victimPredicate = getVictimPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [advancedFilterPredicate, victimPredicate])
        }

        if let aggressorPredicate = getAggressorPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [advancedFilterPredicate, aggressorPredicate])
        }
        
        return advancedFilterPredicate
    }
    
    
    func getDateIntervalPredicate() -> NSPredicate {
        
        var interval = Date.ALL
        if let userInterval = defaults.string(forKey: Filter.Basic.DATE_INTERVAL) {
            interval = userInterval
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Foundation.Date())
        
        //Default to 100 years, an approximate of ALL
        var intervalDate = (calendar as NSCalendar).date(byAdding: .year, value: -100, to: today, options: [])!
        
        switch interval {
        case Date.DAYS_30:
            intervalDate = (calendar as NSCalendar).date(byAdding: .day, value: -30, to: today, options: [])!
        case Date.DAYS_60:
            intervalDate = (calendar as NSCalendar).date(byAdding: .day, value: -60, to: today, options: [])!
        case Date.DAYS_120:
            intervalDate = (calendar as NSCalendar).date(byAdding: .day, value: -120, to: today, options: [])!
        case Date.YEARS_1:
            intervalDate = (calendar as NSCalendar).date(byAdding: .year, value: -1, to: today, options: [])!
        default:
            break
        }
        
        let intervalPredicate = NSPredicate(format: "(date > %@)", intervalDate as CVarArg )
        
        return intervalPredicate
        
    }
    
    
    func getKeywordPredicate(_ keywordType: String) -> NSPredicate? {
        var keywordPredicate: NSPredicate? = nil
        var keyword = String()
        if let userKeyword: String = defaults.string(forKey: keywordType) {
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
        
        
        let userDefaultCurrentEnabled = defaults.bool(forKey: Filter.Basic.CURRENT_SUBREGION_ENABLED)
        
        if userDefaultCurrentEnabled {
            if let userDefaultCurrentSubregion = defaults.string(forKey: Filter.Basic.CURRENT_SUBREGION) {
                currentSubregionPredicate = NSPredicate(format: "(subregion = %@)", userDefaultCurrentSubregion )
            }
        }
        
        return currentSubregionPredicate
    }
    
    
    func getDatePredicate() -> NSPredicate {
        var dateNames: [String] = []
        var dateValues: [AnyObject] = []
        
        
        if let userDefaultStartDate: Foundation.Date = defaults.object(forKey: Filter.Advanced.START_DATE) as? Foundation.Date {
            dateNames.append("(date > %@)")
            dateValues.append(userDefaultStartDate as AnyObject)
        } else {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Foundation.Date())

            let approxOneYearAgo = (calendar as NSCalendar).date(byAdding: .year, value: -1, to: today, options: [])!
                
            dateNames.append("(date > %@)")
            dateValues.append(approxOneYearAgo as AnyObject)
        }
        
        if let userDefaultEndDate: Foundation.Date = defaults.object(forKey: Filter.Advanced.END_DATE) as? Foundation.Date {
            dateNames.append("(date < %@)")
            dateValues.append(userDefaultEndDate as AnyObject)
        } else {
            dateNames.append("(date < %@)")
            dateValues.append(Foundation.NSDate())
        }
        
        let datePredicateFormat = buildPredicateFormat(AND_PREDICATE, names: dateNames)
        let datePredicate = NSPredicate(format: datePredicateFormat, argumentArray: dateValues)

        return datePredicate
    }

    
    func getSubregionPredicate() -> NSPredicate? {
        var subregionPredicate: NSPredicate? = nil
        var regionNames = [String]()
        var regionValues = [AnyObject]()
        
        if let userDefaultSubRegion: Array<String> = defaults.object(forKey: Filter.Advanced.SELECTED_REGION) as? Array<String> {
            if userDefaultSubRegion.count > 0 {
                for (region) in userDefaultSubRegion {
                    regionNames.append("(subregion = %@)")
                    regionValues.append(region as AnyObject)
                }
                
                let subregionPredicateFormat = buildPredicateFormat(OR_PREDICATE, names: regionNames)
                subregionPredicate = NSPredicate(format: subregionPredicateFormat, argumentArray: regionValues)
            }
        }

        return subregionPredicate
    }
    
    
    func getRefNumPredicate() -> NSPredicate? {
        var refNumPredicate: NSPredicate? = nil
        
        if let userDefaultRefNum = defaults.string(forKey: Filter.Advanced.REFERENCE_NUM) {
            var refNumNames = String()
            var refNumValues = String()
            
            let refNum = userDefaultRefNum.components(separatedBy: Filter.Advanced.REF_SEPARATER)
        
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
        
        if let userDefaultVictim = defaults.string(forKey: Filter.Advanced.VICTIM) {
            if !userDefaultVictim.isEmpty {
                victimPredicate = NSPredicate(format: "(victim CONTAINS[c] %@)", userDefaultVictim)
            }
        }
        
        return victimPredicate
    }
    
    
    func getAggressorPredicate() -> NSPredicate? {
        var aggressorPredicate: NSPredicate? = nil
        
        if let userDefaultAggressor = defaults.string(forKey: Filter.Advanced.AGGRESSOR) {
            if !userDefaultAggressor.isEmpty {
                aggressorPredicate = NSPredicate(format: "(aggressor CONTAINS[c] %@)", userDefaultAggressor)
            }
        }
        
        return aggressorPredicate
    }
    
  
    func buildPredicateFormat(_ predicateType: String, names: [String]) -> String {
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
