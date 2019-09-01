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

    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    var managedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
    }
    
    func populateEntity(_ asams: [[String:Any]]) {
        addAsams(asams)
    }
    
    func addAsams(_ asams: [[String:Any]]) {
        let entity = NSEntityDescription.entity(forEntityName: ASAM_ENTITY, in: managedContext)
        
        for json: [String:Any] in asams {
            let asam: Asam = NSManagedObject(entity: entity!, insertInto:managedContext) as! Asam
            
            if let reference = json["Reference"] as? String {
                asam.reference = reference
            }
            if let latitude = json["lat"] as? String {
                asam.latitude = latitude.getDouble
            }
            if let longitude = json["lng"] as? String {
                asam.longitude = longitude.getDouble
            }
            if let subregion = json["Subregion"] as? String {
                asam.subregion = Int(subregion)!
            }
            if let hostility = json["Aggressor"] as? String {
                asam.hostility = hostility
            }
            if let victim = json["Victim"] as? String {
                asam.victim = victim
            }
            if let detail = json["Description"] as? String {
                asam.detail = detail
            }
            if let date = json["Date"] as? String {
                asam.date = dateFormatter.date(from: date)!
            }
            
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
        print(message + " \(String(describing: error)): \(String(describing: error?.userInfo))")
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

        if let hostilityPredicate = getHostilityPredicate() {
            advancedFilterPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [advancedFilterPredicate, hostilityPredicate])
        }
        
        return advancedFilterPredicate
    }
    
    func getDateIntervalPredicate() -> NSPredicate {
        
        var interval = DateQuery.ALL
        if let userInterval = UserDefaults.standard.string(forKey: Filter.Basic.DATE_INTERVAL) {
            interval = userInterval
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Foundation.Date())
        
        //Default to 100 years, an approximate of ALL
        var intervalDate = (calendar as NSCalendar).date(byAdding: .year, value: -100, to: today, options: [])!
        
        switch interval {
        case DateQuery.DAYS_30:
            intervalDate = (calendar as NSCalendar).date(byAdding: .day, value: -30, to: today, options: [])!
        case DateQuery.DAYS_60:
            intervalDate = (calendar as NSCalendar).date(byAdding: .day, value: -60, to: today, options: [])!
        case DateQuery.DAYS_120:
            intervalDate = (calendar as NSCalendar).date(byAdding: .day, value: -120, to: today, options: [])!
        case DateQuery.YEARS_1:
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
        if let userKeyword: String = UserDefaults.standard.string(forKey: keywordType) {
            keyword = userKeyword
        }
        
        if !keyword.isEmpty {
            var intervalNames: [String] = []
            var intervalValues: [String] = []
            
            intervalNames.append("(hostility CONTAINS[c] %@)")
            intervalValues.append(keyword)
            intervalNames.append("(date CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(detail CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(latitude CONTAINS %@)")
            intervalValues.append(keyword)
            intervalNames.append("(longitude CONTAINS %@)")
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
        
        
        let userDefaultCurrentEnabled = UserDefaults.standard.bool(forKey: Filter.Basic.CURRENT_SUBREGION_ENABLED)
        
        if userDefaultCurrentEnabled {
            if let userDefaultCurrentSubregion = UserDefaults.standard.string(forKey: Filter.Basic.CURRENT_SUBREGION) {
                currentSubregionPredicate = NSPredicate(format: "(subregion = %@)", userDefaultCurrentSubregion )
            }
        }
        
        return currentSubregionPredicate
    }
    
    func getDatePredicate() -> NSPredicate {
        var dateNames: [String] = []
        var dateValues: [AnyObject] = []
        
        
        if let userDefaultStartDate: Foundation.Date = UserDefaults.standard.object(forKey: Filter.Advanced.START_DATE) as? Foundation.Date {
            dateNames.append("(date > %@)")
            dateValues.append(userDefaultStartDate as AnyObject)
        } else {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Foundation.Date())

            let approxOneYearAgo = (calendar as NSCalendar).date(byAdding: .year, value: -1, to: today, options: [])!
                
            dateNames.append("(date > %@)")
            dateValues.append(approxOneYearAgo as AnyObject)
        }
        
        if let userDefaultEndDate: Foundation.Date = UserDefaults.standard.object(forKey: Filter.Advanced.END_DATE) as? Foundation.Date {
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
        
        if let userDefaultSubRegion: Array<String> = UserDefaults.standard.object(forKey: Filter.Advanced.SELECTED_REGION) as? Array<String> {
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
        
        if let userDefaultRefNum = UserDefaults.standard.string(forKey: Filter.Advanced.REFERENCE_NUM) {
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
        
        if let userDefaultVictim = UserDefaults.standard.string(forKey: Filter.Advanced.VICTIM) {
            if !userDefaultVictim.isEmpty {
                victimPredicate = NSPredicate(format: "(victim CONTAINS[c] %@)", userDefaultVictim)
            }
        }
        
        return victimPredicate
    }
    
    func getHostilityPredicate() -> NSPredicate? {
        var predicate: NSPredicate? = nil
        
        if let defaultHostility = UserDefaults.standard.string(forKey: Filter.Advanced.HOSTILITY) {
            if !defaultHostility.isEmpty {
                predicate = NSPredicate(format: "(hostility CONTAINS[c] %@)", defaultHostility)
            }
        }
        
        return predicate
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
