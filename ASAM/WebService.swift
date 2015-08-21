//
//  WebService.swift
//  ASAM
//
//  Created by Chris Wasko on 8/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

protocol WebService {
    func didReceiveResponse(results: NSArray)
}


class AsamRetrieval: NSObject {
    
    var data: NSMutableData = NSMutableData()
    var delegate: WebService?
    
    func searchAllAsams() {
        
        var urlPath = "http://msi.nga.mil/MSI_JWS/ASAM_JSON/getJSON"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        
        println("Searching: \(url)")
        
        connection.start()
    }

    
    func searchForAsams(startDate: String, endDate: String) {
        
        //Dateformate yyyMMdd
        var urlPath = "http://msi.nga.mil/MSI_JWS/ASAM_JSON/getJSON?typename=DateRange_AllRefNumbers&fromDate=" + startDate + "&toDate=" + endDate
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        
        println("Searching: \(url)")
        
        connection.start()
    }
    
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Failed with error:\(error.localizedDescription)")
    }
    
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        //New request, clear the data object
        self.data = NSMutableData()
    }
    
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        
        //Perform data manipulation to remove tabs
        var stringData = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let newString: NSString = stringData!.stringByReplacingOccurrencesOfString("\t", withString: " ")
        
        let utf8str = newString.dataUsingEncoding(NSUTF8StringEncoding)
        
        // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
        let base64Encoded = utf8str!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        var newData = NSData(base64EncodedString: base64Encoded, options:   NSDataBase64DecodingOptions(rawValue: 0))
        
        self.data.appendData(newData!)
    }
    
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        var error:NSError? = nil
        if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:&error) {
            if let jsonArray = jsonObject as? NSArray {
                delegate?.didReceiveResponse(jsonArray)
            } else {
                println("Not an Array")
            }
        } else {
            println("Could not parse JSON: \(error!)")
        }
        
    }


    deinit {
        println("deiniting")
    }
    
    
    
}