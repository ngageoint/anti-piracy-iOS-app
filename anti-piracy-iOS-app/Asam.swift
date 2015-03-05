//
//  Asam.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 3/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import CoreData

@objc(Asam)
class Asam: NSManagedObject {

    @NSManaged var aggressor: String
    @NSManaged var date: NSDate
    @NSManaged var desc: String
    @NSManaged var lat: NSNumber
    @NSManaged var latitude: String
    @NSManaged var lng: NSNumber
    @NSManaged var longitude: String
    @NSManaged var reference: String
    @NSManaged var subregion: NSNumber
    @NSManaged var victim: String

}
