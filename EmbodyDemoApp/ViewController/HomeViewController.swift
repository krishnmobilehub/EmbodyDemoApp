//
//  HomeViewController.swift
//  EmbodyDemoApp
//

import UIKit
import Foundation

class HomeViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var offlineVideoButton: UIButton!
    @IBOutlet weak var onlineVideoButton: UIButton!
    
    private lazy var cameraManager = CameraServices.sharedInstance

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        offlineVideoButton.buttonCornerRadious(borderColor: .black, isShadow: true)
        onlineVideoButton.buttonCornerRadious(borderColor: .black, isShadow: true)
    }
    
//    MARK: - Button Action Methods
    @IBAction func offlineVideoClicked(_ sender: Any) {
        self.faceScanView()
    }
    
    @IBAction func onlineVideoClicked(_ sender: Any) {
        self.faceScanView(isOnline: true)
    }
    
    func faceScanView(isOnline: Bool = false) {
        cameraManager.checkCameraAccess(onCompleted: { (access) in
            if access {
                let faceScanningViewController = UIStoryboard().instantiateViewController(withClass: FaceScanningViewController.self)
                faceScanningViewController.stream = isOnline ? .online : .offline
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(faceScanningViewController, animated: true)
                }
            } else {
                self.redirectToSettingView()
            }
        })
    }
    
    func redirectToSettingView() {
        self.showAlert(withMessage: Message.noCameraAccessMessage, title: Title.alertTitle, rightButton: Title.setting) { (buttonTag) in
            if buttonTag == .right {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (_) in

                    })
                }
            }
        }
    }
}
