//
//  AsamJsonParser.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AsamJsonParser : JsonParser {
    
    let path = NSBundle.mainBundle().pathForResource("asam", ofType: "json")
    var asams = [NSManagedObject]()
    

    
    override init()
    {
 
        
        super.init()
        let json:[String: String] = generateDictionaryFromJson(path!)
        
        
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Asam",
            inManagedObjectContext:
            managedContext)
        
        let asam = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3
        asam.setValue(json["Reference"]!, forKey: "reference")
        asam.setValue(json["Aggressor"]!, forKey: "aggressor")
        asam.setValue(json["Victim"]!, forKey: "victim")
        asam.setValue(json["Description"]!, forKey: "desc")
        asam.setValue(json["Latitude"]!, forKey: "latitude")
        asam.setValue(json["Longitude"]!, forKey: "longitude")
        
        //doubles
        asam.setValue((json["lat"]! as String).doubleValue, forKey: "lat")
        asam.setValue((json["lng"]! as String).doubleValue, forKey: "lng")

        //integers
        asam.setValue((json["Subregion"]! as String).toInt(), forKey: "subregion")
        
        //dates
        let dateString: String = json["Date"]!
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let date = formatter.dateFromString(dateString)
        asam.setValue(date, forKey: "date")
    
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }  
        //5
        asams.append(asam)
    
    
    }
    
    

}