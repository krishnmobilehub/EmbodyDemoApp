//
//  FaceScanViewController.swift
//  EmbodyDemoApp
//

import UIKit
import MLKitFaceDetection
import AVFoundation
import MLKitVision

class FaceScanningViewController: UIViewController {
    
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!

    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private lazy var cameraManager = CameraServices.sharedInstance
    var stream: Stream = Stream.offline
    var isRedirectVideoList = false
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.addVideoOutput()
        self.addPreviewLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    func startScanning() {
        self.faceImageView.isHidden = false
        self.captureSession.startRunning()
        self.previewLayer.isHidden = false
    }
    
    func stopScanning() {
        self.faceImageView.isHidden = true
        self.captureSession.stopRunning()
        self.previewLayer.isHidden = true
    }
    
    private func addCameraInput() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        let videoDevices = deviceDiscoverySession.devices
        var captureDevice: AVCaptureDevice
        for device in videoDevices {
            if device.position == .front {
                captureDevice = device
                let cameraInput = try! AVCaptureDeviceInput(device: captureDevice)
                self.captureSession.addInput(cameraInput)
                break
            }
        }
    }
    
    private func addPreviewLayer() {
        self.view.layer.addSublayer(self.previewLayer)
        view.bringSubviewToFront(faceImageView)
        view.bringSubviewToFront(backButton)
    }
    
    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.embodydemo.queue"))
        self.captureSession.addOutput(self.videoOutput)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    func initFaceScanning(sampleBuffer: CMSampleBuffer) {
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.classificationMode = .all
            
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .front)

        let faceDetector = FaceDetector.faceDetector(options: options)
        
        faceDetector.process(visionImage) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                return
            }
            
            // FACE DETECTED
            for face in faces {
                if face.hasHeadEulerAngleX && -10...10 ~= face.headEulerAngleX &&
                    face.hasHeadEulerAngleY && -8...8 ~= face.headEulerAngleY &&
                    face.hasHeadEulerAngleZ && -5...5 ~= face.headEulerAngleZ &&
                    face.hasSmilingProbability && face.smilingProbability < 0.10 &&
                    face.hasLeftEyeOpenProbability && face.leftEyeOpenProbability > 0.50 &&
                    face.hasRightEyeOpenProbability && face.rightEyeOpenProbability > 0.50 {
                    self.stopScanning()
                    self.redirectToVideoListView()
                    self.isRedirectVideoList = true
                    break
                }
            }
        }
    }
    
    func redirectToVideoListView() {
        if !isRedirectVideoList {
            let videoListViewController = UIStoryboard().instantiateViewController(withClass: VideoListViewController.self)
            videoListViewController.stream = self.stream
            self.navigationController?.pushViewController(videoListViewController, animated: true)
        }
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FaceScanningViewController {
    func imageOrientation(deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            break
        }
        return .up
    }
}

extension FaceScanningViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.initFaceScanning(sampleBuffer: sampleBuffer)
    }
}
