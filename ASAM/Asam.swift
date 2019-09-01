//
//  Asam.swift
//  anti-piracy-iOS-app
//


import Foundation
import CoreData

@objc(Asam)
class Asam: NSManagedObject {

    @NSManaged var hostility: String
    @NSManaged var date: Foundation.Date
    @NSManaged var detail: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var reference: String
    @NSManaged var subregion: Int
    @NSManaged var victim: String

}
