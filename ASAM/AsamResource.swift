//
//  AsamResource.swift
//  ASAM
//

import Foundation

protocol AsamResourceDelegate {
    func success(_ results: [[String:Any]])
    func error(_ error: Error?)
}

class AsamResource: NSObject {
    
    var data: NSMutableData = NSMutableData()
    var delegate: AsamResourceDelegate?
    var model = AsamModelFacade()

    func query() {
        var urlPath = "https://msi.gs.mil/api/publications/asam?sort=date&output=html"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let latestAsamDate = model.getLatestAsamDate() {
            urlPath += "&minOccurDate=" + formatter.string(from: latestAsamDate) + "&maxOccurDate=" + formatter.string(from: Foundation.Date())
        }
        
        query(urlPath)
    }
    
    fileprivate func query(_ urlPath: String) {
        guard let url = URL(string: urlPath) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.error(error)
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with:dataResponse, options: []) as? [String: Any]
                if let asams = json?["asam"] as? [[String:Any]] {
                    DispatchQueue.main.async {
                        self.model.addAsams(asams)
                        UserDefaults.standard.set(Date(), forKey:AppSettings.LAST_SYNC)
                        self.delegate?.success(asams)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.error(nil)
                    }
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}
