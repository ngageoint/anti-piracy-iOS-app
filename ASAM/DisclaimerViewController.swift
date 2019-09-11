//
//  DisclaimerViewController.swift
//  ASAM
//
//  Created by William Newman on 8/31/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import UIKit

class DisclaimerViewController: UIViewController {
    
    @IBOutlet weak var disclaimer: UITextView!

    override func viewDidLayoutSubviews() {
        disclaimer.setContentOffset(.zero, animated: false)
    }
    
    @IBAction func onAgreeTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loadingViewController")
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBAction func onExitTapped(_ sender: Any) {
        UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
    }
    
    @IBAction func onShowDisclaimerTapped(_ sender: Any) {
        if let disclaimerSwitch = sender as? UISwitch {
            UserDefaults.standard.set(!disclaimerSwitch.isOn, forKey: AppSettings.HIDE_DISCLAIMER)
        }
    }
}
