//
//  AboutViewController.swift
//  ASAM
//
//  Created by William Newman on 9/1/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController, AsamResourceDelegate {
    var asamResource: AsamResource = AsamResource()
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    var syncing = false
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        asamResource.delegate = self
        
        activityIndicator.color = UIColor.init(red: 229/255, green: 57/255, blue: 53/255, alpha: 1.0)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 2) {
            if let date = UserDefaults.standard.object(forKey: AppSettings.LAST_SYNC) as? Date {
                cell.detailTextLabel!.text = dateFormatter.string(from: date)
            } else {
                cell.detailTextLabel!.text = "Never Sync'ed"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2 && !syncing) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            activityIndicator.startAnimating()
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryView = activityIndicator
            asamResource.query()
            syncing = true
        }
    }
    
    func success(_ results: [[String : Any]]) {
        stopAnimating()
    }
    
    func error(_ error: Error?) {
        stopAnimating()
    }
    
    fileprivate func stopAnimating() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
        cell?.accessoryView = nil
        syncing = false
    }
}
