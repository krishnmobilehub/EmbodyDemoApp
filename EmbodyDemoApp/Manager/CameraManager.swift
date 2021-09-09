//
//  CameraManager.swift
//  EmbodyDemoApp
//

import Foundation
import AVKit

class CameraServices: NSObject {
    static let sharedInstance: CameraServices = {
        let instance = CameraServices()
        return instance
    }()
    
    private var cameraManager: AVCaptureDevice?
    
    override init() {
        super.init()
    }
    
    func checkCameraAccess(onCompleted:@escaping(Bool)->()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            onCompleted(false)
        case .authorized:
            onCompleted(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    onCompleted(true)
                } else {
                    onCompleted(false)
                }
            }
        default:
            break;
        }
    }
}
