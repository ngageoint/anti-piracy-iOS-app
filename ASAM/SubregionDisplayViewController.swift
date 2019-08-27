//
//  SubregionDisplay.swift
//  anti-piracy-iOS-app
//

import Foundation
import UIKit

class SubregionDisplayViewController: UIViewController {
    
    func populateRegionText(_ regions: Array<String>, textView: UITextField) {
        var regionsText = String()
        
        for region in regions {
            regionsText += region + ","
        }
    
        if !regions.isEmpty {
            textView.text = regionsText.substring(to: regionsText.characters.index(before: regionsText.endIndex))
        }
        else {
            textView.text = String()
        }
    
    }
    
}
