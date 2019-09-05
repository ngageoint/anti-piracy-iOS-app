//
//  Asam.swift
//  anti-piracy-iOS-app
//


import Foundation
import CoreData
import MapKit

@objc(Asam)
class Asam: NSManagedObject, MKAnnotation {

    @NSManaged var hostility: String
    @NSManaged var date: Foundation.Date
    @NSManaged var detail: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var reference: String
    @NSManaged var subregion: Int
    @NSManaged var navArea: String
    @NSManaged var victim: String
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
