//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Nelson Gonzalez on 3/20/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    var captureSesion: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaptureSession()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        captureSesion.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        captureSesion.stopRunning()
    }
    
    /* 3 parts of recording video:
    
     - capture session
     - input (captureDevice)
     - output (data, movie, etc)
     
    */
    
    //delegate
    
    //the recording gets output on a background queue
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        DispatchQueue.main.async {
            
            defer {self.updateViews()}
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                guard status == .authorized else {
                    NSLog("Please give video filterd access to photo library in settings")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                
             
                    
                }, completionHandler: { (success, error) in
                     //remove it from documents. we just want one in the photo library. This removes it
                      try! FileManager.default.removeItem(at: outputFileURL)
                    
                    if let error = error {
                        NSLog("Error saving video to phopto library: \(error)")
                    }
                })
            })
        }
    }
    
    
    func setupCaptureSession() {
        //make the capture session
        let captureSession = AVCaptureSession()
        //configure the inputs
        let cameraDevice = bestCamera()
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {return}
        
        guard let cameraDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice), /* guard */ captureSession.canAddInput(cameraDeviceInput) else {
            fatalError("Unable to create camera input")
        }
        
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {return}
        
        //"take this camera and use it to record video when the session begins"
        captureSession.addInput(cameraDeviceInput)
        captureSession.addInput(audioDeviceInput)
        
        //configure outputs
        let fileOutput = AVCaptureMovieFileOutput()
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Unable to add movie file output to capture session")
        }
        
        captureSession.addOutput(fileOutput)
        
        
        //configure the session
        
        captureSession.sessionPreset = .hd1920x1080
        //ready to begin running everything
        captureSession.commitConfiguration()//lock in the inputs, outputs, session presets, etc
      
        self.captureSesion = captureSession
        self.recordOutput = fileOutput
        
        //gives the video information frames to the preview view to be shown to the user
        cameraPreviewView.videoPreviewLayer.session = captureSession
        
    }
     //* AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .front)*
    
    
    
    private func bestCamera() -> AVCaptureDevice {
        //the users device has a dual camera
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else  if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            //single camera on users device
            return device
            
        } else {
            fatalError("Missing expected back camera on device")
        }
        
    }
    
    private func updateViews() {
    
        let isRecording = recordOutput.isRecording
        
        let recordButtonImage = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImage), for: .normal)
        
    }
    
    private func newRecordingURL() -> URL {
        
        let documentDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if recordOutput.isRecording {
           recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
        
        
        
    }
    
}
