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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entity(forEntityName: "Asam", in:managedContext)
        
        let json: NSDictionary = generateDictionaryFromJson(path!) as! NSDictionary
        let dataArray = json["asams"]as! NSArray;
        for item in dataArray { 
            let obj = item as! NSDictionary
            let asam = NSManagedObject(entity: entity!, insertInto:managedContext)
            
            asam.setValue(obj["Reference"]!, forKey: "reference")
            asam.setValue(obj["Aggressor"]!, forKey: "aggressor")
            asam.setValue(obj["Victim"]!, forKey: "victim")
            asam.setValue(obj["Description"]!, forKey: "desc")
            asam.setValue(obj["Latitude"]!, forKey: "latitude")
            asam.setValue(obj["Longitude"]!, forKey: "longitude")
            
            asam.setValue((obj["lat"]! as! String).getDouble, forKey: "lat")
            asam.setValue((obj["lng"]! as! String).getDouble, forKey: "lng")
            
            asam.setValue(Int((obj["Subregion"]! as! String)), forKey: "subregion")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.date(from: obj["Date"] as! String)
            print(date)
            asam.setValue(date, forKey: "date")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            asams.append(asam)
        }
    }
    
    func generateDictionaryFromJson(_ path: String) -> AnyObject {
        let fileContent = try? Data(contentsOf: URL(fileURLWithPath: path))
        let jsonDict: AnyObject? = try? JSONSerialization.jsonObject(with: fileContent!, options: []) as AnyObject
        return jsonDict!
    }
    
}
