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
        let firstLaunch = UserDefaults.standard.bool(forKey: AppSettings.FIRST_LAUNCH)
        if !firstLaunch {
            let urlPath = "https://msi.nga.mil/MSI_JWS/ASAM_JSON/getJSON"
            query(urlPath)
            UserDefaults.standard.setValue(true, forKey: AppSettings.FIRST_LAUNCH)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd" //ex: "20150221"
            let startDate = formatter.string(from: model.getLatestAsamDate())
            let endDate = formatter.string(from: Foundation.Date())
            let urlPath = "https://msi.nga.mil/MSI_JWS/ASAM_JSON/getJSON?typename=DateRange_AllRefNumbers&fromDate=" + startDate + "&toDate=" + endDate
            query(urlPath)
        }
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
                let json = try JSONSerialization.jsonObject(with:dataResponse, options: [])
                if let jsonArray = json as? [[String:Any]] {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(Date(), forKey:AppSettings.LAST_SYNC)
                        self.delegate?.success(jsonArray)
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
