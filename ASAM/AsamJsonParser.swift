//
//  AsamJsonParser.swift
//  anti-piracy-iOS-app
//


import Foundation
import UIKit
import CoreData

class AsamJsonParser {
    
    let path = NSBundle.mainBundle().pathForResource("asam", ofType: "json")
    var asams = [NSManagedObject]()
    
    init() {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Asam",
            inManagedObjectContext:
            managedContext)
        
        let json: NSDictionary = generateDictionaryFromJson(path!) as! NSDictionary
        let dataArray = json["asams"]as! NSArray;
        for item in dataArray { 
            let obj = item as! NSDictionary
            let asam = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            //3
            asam.setValue(obj["Reference"]!, forKey: "reference")
            asam.setValue(obj["Aggressor"]!, forKey: "aggressor")
            asam.setValue(obj["Victim"]!, forKey: "victim")
            asam.setValue(obj["Description"]!, forKey: "desc")
            asam.setValue(obj["Latitude"]!, forKey: "latitude")
            asam.setValue(obj["Longitude"]!, forKey: "longitude")
            
            //doubles
            asam.setValue((obj["lat"]! as! String).getDouble, forKey: "lat")
            asam.setValue((obj["lng"]! as! String).getDouble, forKey: "lng")
            
            //integers
            asam.setValue(Int((obj["Subregion"]! as! String)), forKey: "subregion")
            
            //dates
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.dateFromString(obj["Date"] as! String)
            print(date)
            asam.setValue(date, forKey: "date")
            
            //4
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }  
            //5
            asams.append(asam)
        }
    }
    
    func generateDictionaryFromJson(path: String) -> AnyObject
    {
        let fileContent = NSData(contentsOfFile: path)
        let jsonDict: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(fileContent!, options: [])
        return jsonDict!
    }
    
}