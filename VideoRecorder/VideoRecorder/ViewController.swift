//
//  ViewController.swift
//  VideoRecorder
//
//  Created by Nelson Gonzalez on 3/20/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeCameraAccess()
   
    }
    
    private func authorizeCameraAccess() {
        
       switch AVCaptureDevice.authorizationStatus(for: .video) {
        
        //the user has previouslty given authorization to use the camera
       case .authorized:
        showCamera()
       case .notDetermined:
        
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.showCamera()
            } else {
                //Show alert saying they cant use the app becasue they didnt allow camera access
            }
        }
        
       case .restricted:
        //the user has restrictions such as parental control, limiting access to their hardware
        return
       case .denied:
            //the user has previsouly denied access to the camera. Prompt them to go to settings anx allow access.
        //user url scheme to show them the settings view
        return
        }
        
        
    }
    
    //returns returns out of the function, break would get out of the switch statment its in.
    
    private func showCamera() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
}

