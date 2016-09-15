//
//  SubregionDisplay.swift
//  anti-piracy-iOS-app
//

import Foundation
import UIKit

class SubregionDisplayViewController: UIViewController {
    
    func populateRegionText(regions: Array<String>, textView: UITextField) {
        var regionsText = String()
        
        for region in regions {
            regionsText += region + ","
        }
    
        if !regions.isEmpty {
            textView.text = regionsText.substringToIndex(regionsText.endIndex.predecessor())
        }
        else {
            textView.text = String()
        }
    
    }
    
}