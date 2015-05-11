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
    
    let defaults = NSUserDefaults.standardUserDefaults()

    
    func getAsams()-> Array<Asam> {
    
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext!

        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Asam")
        
        //build predicate for query
        var filterNames: [String] = []
        var filterValues: [AnyObject] = []
        
        //start date filter
        if let userDefaultStartDate: NSDate = defaults.objectForKey("startDate") as? NSDate {
            filterNames.append("(date > %@)")
            filterValues.append(userDefaultStartDate)
        }
        
        //end date filter
        if let userDefaultEndDate: NSDate = defaults.objectForKey("endDate") as? NSDate {
            filterNames.append("(date < %@)")
            filterValues.append(userDefaultEndDate)
        }
        
        //build predicate string
        var predicateString = String()
        if filterNames.count > 0 {
            for index in 0...(filterNames.count-1) {
                predicateString += filterNames[index]
                if index < filterNames.count-1 {
                    predicateString += " and "
                }
            }
            
            let pred = NSPredicate(format: predicateString, argumentArray: filterValues)
            fetchRequest.predicate = pred
            
        }
        
        let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Asam]
        asams = fetchResults!
        
        return asams
        
    }
    
}