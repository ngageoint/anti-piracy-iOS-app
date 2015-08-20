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
        self.data.appendData(data)
    }
    
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSErrorPointer = nil
        var jsonArray: NSArray = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: err) as! NSArray
        if err != nil {
            println("Error: \(err.debugDescription)")
        }
        delegate?.didReceiveResponse(jsonArray)
    }


    deinit {
        println("deiniting")
    }
    
    
    
}