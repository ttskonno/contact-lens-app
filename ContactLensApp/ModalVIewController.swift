//
//  ModalVIewController.swift
//  ContactLensApp
//
//  Created by KonnoTatsuki on 6/30/15.
//  Copyright (c) 2015 KonnoTatsuki. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController
{
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
    }
    
    @IBAction func closeAction(sender: AnyObject) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
}
