//
//  LoadingController.swift
//  ASAM
//
//  Created by William Newman on 8/29/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import UIKit

class LoadingController: UIViewController, AsamResourceDelegate {
    
    var asamResource: AsamResource = AsamResource()
    var model = AsamModelFacade()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        asamResource.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        asamResource.query()
    }
    
    func success(_ json: [[String:Any]]) {
        model.populateEntity(json)
        performSegue(withIdentifier: "launchSegue", sender: self)
    }
    
    func error(_ error: Error?) {
        print(error?.localizedDescription ?? "Response Error")
        performSegue(withIdentifier: "launchSegue", sender: self)
    }
}
