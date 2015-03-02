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
        var json:NSDictionary = generateDictionaryFromJson(path!)
        
        
        
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
        asam.setValue("123123123", forKey: "reference")
        asam.setValue("joMama", forKey: "victim")
        
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }  
        //5
        asams.append(asam)
    
    
    }
    

}