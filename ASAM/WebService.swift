//
//  WebService.swift
//  ASAM
//


import Foundation

protocol WebService {
    func didReceiveResponse(_ results: NSArray)
}


class AsamRetrieval: NSObject {
    
    var data: NSMutableData = NSMutableData()
    var delegate: WebService?
    

    func searchAllAsams() {
        let urlPath = "http://msi.nga.mil/MSI_JWS/ASAM_JSON/getJSON"
        searchAsams(urlPath)
    }

    
    func searchForAsams(_ startDate: String, endDate: String) {
        //Dateformate yyyyMMdd
        let urlPath = "http://msi.nga.mil/MSI_JWS/ASAM_JSON/getJSON?typename=DateRange_AllRefNumbers&fromDate=" + startDate + "&toDate=" + endDate
        searchAsams(urlPath)
    }
    
    
    func searchAsams(_ urlPath: String) {
        let url: URL = URL(string: urlPath)!
        let request: URLRequest = URLRequest(url: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        
        print("Searching: \(url)")
        
        connection.start()
    }
    
    
    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
        print("Failed with error:\(error.localizedDescription)")
    }
    
    
    func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        //New request, clear the data object
        self.data = NSMutableData()
    }
    
    
    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        
        //Perform data manipulation to remove extra whitespace
        let stringData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        let nonTrimData: NSString = stringData!.replacingOccurrences(of: "[\\s+]", with: "  ", options: NSString.CompareOptions.regularExpression, range: NSRange(location: 0, length: stringData!.length)) as NSString
        let trimData: NSString = nonTrimData.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let utf8str = trimData.data(using: String.Encoding.utf8.rawValue)
        
        // fromRaw(0) is equivalent to objc 'base64EncodedStringWithOptions:0'
        let base64Encoded = utf8str!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let newData = Data(base64Encoded: base64Encoded, options:   NSData.Base64DecodingOptions(rawValue: 0))
        
        self.data.append(newData!)
    }
    
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        
        if data.length > 0 {
            do {
                let jsonObject: Any = try JSONSerialization.jsonObject(with: data as Data, options: [])
                if let jsonArray = jsonObject as? NSArray {
                    delegate?.didReceiveResponse(jsonArray)
                } else {
                    print("Not an Array")
                }
            } catch let error as NSError {
                print("Could not parse JSON: \(error)")
            }
        } else {
            print("No data returned")
        }
        
    }


    deinit {
        print("deiniting")
    }
    
    
    
}
