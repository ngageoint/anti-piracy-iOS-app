//
//  JsonParser.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

class JsonParser {
        
    func generateDictionaryFromJson(path: String) -> NSDictionary
    {
        let fileContent = NSData(contentsOfFile: path)
        var error: NSError?
        var jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(fileContent!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        return jsonDict
    }
    
    
}