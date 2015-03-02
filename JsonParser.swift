//
//  JsonParser.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

class JsonParser {
        
    func generateDictionaryFromJson(path: String) -> [String: String]
    {
        let fileContent = NSData(contentsOfFile: path)
        var error: NSError?
        var jsonDict: [String: String] = NSJSONSerialization.JSONObjectWithData(fileContent!, options: NSJSONReadingOptions.MutableContainers, error: &error) as [String: String]
        return jsonDict
    }
    
    
}