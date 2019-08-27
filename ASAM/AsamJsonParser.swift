//
//  AsamJsonParser.swift
//  anti-piracy-iOS-app
//


import Foundation
import UIKit
import CoreData

class AsamJsonParser {
    
    let path = Bundle.main.path(forResource: "asam", ofType: "json")
    var asams = [NSManagedObject]()
    
    init() {
        //1
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entity(forEntityName: "Asam",
            in:
            managedContext)
        
        let json: NSDictionary = generateDictionaryFromJson(path!) as! NSDictionary
        let dataArray = json["asams"]as! NSArray;
        for item in dataArray { 
            let obj = item as! NSDictionary
            let asam = NSManagedObject(entity: entity!,
                insertInto:managedContext)
            
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
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.date(from: obj["Date"] as! String)
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
    
    func generateDictionaryFromJson(_ path: String) -> AnyObject
    {
        let fileContent = try? Data(contentsOf: URL(fileURLWithPath: path))
        let jsonDict: AnyObject? = try? JSONSerialization.jsonObject(with: fileContent!, options: []) as AnyObject
        return jsonDict!
    }
    
}
