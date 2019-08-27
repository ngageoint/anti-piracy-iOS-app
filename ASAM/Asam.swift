//
//  Asam.swift
//  anti-piracy-iOS-app
//


import Foundation
import CoreData

@objc(Asam)
class Asam: NSManagedObject {

    @NSManaged var aggressor: String
    @NSManaged var date: Foundation.Date
    @NSManaged var desc: String
    @NSManaged var lat: NSNumber
    @NSManaged var latitude: String
    @NSManaged var lng: NSNumber
    @NSManaged var longitude: String
    @NSManaged var reference: String
    @NSManaged var subregion: NSNumber
    @NSManaged var victim: String

}
