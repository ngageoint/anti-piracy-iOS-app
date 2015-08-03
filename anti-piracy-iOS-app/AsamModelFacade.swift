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

    
    func getAsams()-> Array<Asam> {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Asam")
        
        fetchRequest.predicate = getFilterPredicate()
        
        let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Asam]
        asams = fetchResults!
        
        return asams
    }
    
    
    func getFilterPredicate() -> NSPredicate {
        
        var filterPredicate = getDatePredicate()

        if let subregionPredicate = getSubregionPredicate() {
            filterPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [filterPredicate, subregionPredicate])
        }
       
        return filterPredicate
    }
    
    
    func getDatePredicate() -> NSPredicate {
        var dateNames: [String] = []
        var dateValues: [AnyObject] = []
        
        
         let userDefaultStartDate = NSDate() //{//defaults.objectForKey("startDate") as? NSDate {
            dateNames.append("(date > %@)")
            dateValues.append(userDefaultStartDate)
     //   }
        
        //if let userDefaultEndDate: NSDate = NSDate() { //defaults.objectForKey("endDate") as? NSDate {
        let userDefaultEndDate = NSDate()
            dateNames.append("(date < %@)")
            dateValues.append(userDefaultEndDate)
      //  }
        
        //build predicate string
        let datePredicateFormat = buildPredicateFormat(AND_PREDICATE, names: dateNames)
        
        var datePredicate = NSPredicate(format: datePredicateFormat, argumentArray: dateValues)

        return datePredicate
    }

    
    func getSubregionPredicate() -> NSPredicate? {
        var subregionPredicate: NSPredicate? = nil
        var regionNames = [String]()
        var regionValues = [AnyObject]()
        
        if let userDefaultSubRegion: Array<String> = defaults.objectForKey("selectedRegions") as? Array<String> {
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