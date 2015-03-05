//
//  JsonParser.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

class JsonParser {
        
    func generateDictionaryFromJson(path: String) -> AnyObject
    {
        let fileContent = NSData(contentsOfFile: path)
        var jsonDict: AnyObject? = NSJSONSerialization.JSONObjectWithData(fileContent!, options: nil, error: nil)
        return jsonDict!
    }
    
    
}