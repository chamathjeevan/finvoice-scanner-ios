    //
    //  ViewController.swift
    //  FakturaSanning
    //
    //  Created by MacBook on 16/9/19.
    //  Copyright © 2019 Nicknamed. All rights reserved.
    //
    
    import UIKit
    import AVFoundation
    import Finvoice
    
    class ViewController: UIViewController {
        
        @IBOutlet weak var viewContainer: UIView!
        @IBOutlet weak var viewDatum: UIView!
        @IBOutlet weak var viewTillKonto: UIView!
        @IBOutlet weak var viewBelopp: UIView!
        @IBOutlet weak var viewMeddelande: UIView!
        @IBOutlet weak var viewAntectning: UIView!
        @IBOutlet weak var viewCurveCamera: UIView!
        @IBOutlet weak var constraintCurveHeight: NSLayoutConstraint!
        @IBOutlet weak var constraintCurveViewTop: NSLayoutConstraint!
        @IBOutlet weak var constraintBottomSpace: NSLayoutConstraint!
        @IBOutlet weak var constraintTopSpace: NSLayoutConstraint!
        @IBOutlet weak var buttonKlar: UIButton!
        @IBOutlet weak var buttonCamera: UIButton!
        @IBOutlet weak var buttonDownArrow: UIButton!
        
        @IBOutlet weak var labelTillKontoTitle: UILabel!
        @IBOutlet weak var labelTillKonto: UILabel!
        @IBOutlet weak var labelDatumTitle: UILabel!
        @IBOutlet weak var labelDatum: UILabel!
        @IBOutlet weak var labelBeloppTitle: UILabel!
        @IBOutlet weak var labelMaddelandeTitle: UILabel!
        @IBOutlet weak var labelAntectningTitle: UILabel!
        @IBOutlet weak var scrollView: UIScrollView!
        
        let CURVE_HEIGHT = (UIScreen.main.fixedCoordinateSpace.bounds.height/100) * 80
        let CURVE_DEFAULT_HEIGHT = (UIScreen.main.fixedCoordinateSpace.bounds.height/100) * 30
        let SCREEN_HIGHT = UIScreen.main.fixedCoordinateSpace.bounds.height
        let invoiceScanner = InvoiceScanner()
        
        internal var captureDevice: AVCaptureDevice!
        internal var isCameraOpen:Bool = false
        internal var captureSession = AVCaptureSession()
        internal var sessionOutPut = AVCaptureVideoDataOutput()
        internal var previewLayer: AVCaptureVideoPreviewLayer?
        
        var numberOfScans: Int = 0
        
        var gestureStartY: CGFloat = 0;
        var previousY: CGFloat = 0;
        
        var panGesture  = UIPanGestureRecognizer()
        var startingConstant: CGFloat  = 0.0
        
        var startingBottonConstant: CGFloat  = 0.0
        
        var isPanGestureCompleted:Bool = false
        
        let ANIMATION_TIME = 0.25
        
        var bufferedPages = Set<InvoicePage>()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            buttonKlar.isEnabled = false
            buttonKlar.backgroundColor = UIColor.darkGray
            startingConstant = CURVE_DEFAULT_HEIGHT - CURVE_HEIGHT;
            
            viewTillKonto.dropShadow()
            viewDatum.dropShadow()
            viewBelopp.dropShadow()
            viewMeddelande.dropShadow()
            viewAntectning.dropShadow()
            
            constraintCurveHeight.constant = CURVE_HEIGHT
            constraintCurveViewTop.constant = startingConstant
            startingBottonConstant = constraintBottomSpace.constant
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidDrag(_:)))
            self.viewCurveCamera.addGestureRecognizer(panGesture)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            
            viewCurveCamera.addBottomRoundedEdge()
            viewCurveCamera.dropShadow(scale: false)
        }
        
        @IBAction func actionScan(_ sender: Any) {
            let alert = UIAlertController(title: title, message: " Message Text", preferredStyle: UIAlertController.Style.alert)
            alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })))
            self.present(alert, animated: true, completion: nil)
        }
        
        func openCameraView(){
            if(!isCameraOpen){
                scrollView.isScrollEnabled = false
                bufferedPages.removeAll()
                self.buttonCamera.alpha = 0
                self.buttonDownArrow.alpha = 0
                
                Analysis.reset()
                
                startCamera()
                
                self.numberOfScans = 0
                self.isCameraOpen = true
            }
        }
        
        func closeCameraView(){
            
            if(isCameraOpen){
                buttonCamera.isHidden = false
                buttonDownArrow.isHidden = false
                
                self.stopCamera()
                
                scrollView.isScrollEnabled = true
                viewCurveCamera.isUserInteractionEnabled = true
                self.isCameraOpen = false
            }
        }
        
        func startCamera() {
            if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.rear)
            {
                do {
                    self.captureDevice = AVCaptureDevice.default(for: .video)
                    try captureDevice.lockForConfiguration()
                    captureDevice.focusMode = .continuousAutoFocus
                    captureDevice.unlockForConfiguration()
                    
                    let cameraInput = try AVCaptureDeviceInput(device: self.captureDevice)
                    if captureSession.canAddInput(cameraInput) {
                        captureSession.addInput(cameraInput)
                    }
                    
                    sessionOutPut.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) as String: kCVPixelFormatType_32BGRA]
                    
                    let queue = DispatchQueue(label: "freamqueue")
                    
                    sessionOutPut.setSampleBufferDelegate(self, queue: queue)
                    sessionOutPut.alwaysDiscardsLateVideoFrames = true
                    
                    if captureSession.canAddOutput(sessionOutPut) {
                        captureSession.addOutput(sessionOutPut)
                    }
                    displayPreview(on: viewCurveCamera)
                    
                    captureSession.startRunning()
                    
                }catch{
                    print("error")
                }
            }
        }
        
        func displayPreview(on view: UIView) {
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer?.connection?.videoOrientation = .portrait
            
            self.previewLayer?.frame = view.frame
            
            let color = CABasicAnimation(keyPath: "borderColor")
            color.fromValue = UIColor.Forcus.cgColor
            color.toValue = UIColor.ForcusLite.cgColor
            color.duration = 1
            color.repeatCount = 100
            
            let boader: CALayer = CALayer()
            
            boader.frame = CGRect(x: 50, y: 50, width: (view.frame.width - 100), height: (view.frame.height - 100))
            boader.borderColor = UIColor.Forcus.cgColor
            boader.borderWidth = 2
            boader.add(color, forKey: "borderColor")
            
            self.previewLayer?.addSublayer(boader)
            view.layer.insertSublayer(self.previewLayer!, at: 0)
            let viewforPangesture:UIView = UIView()
            viewforPangesture.frame = self.view.bounds
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidDrag(_:)))
            viewforPangesture.addGestureRecognizer(panGesture)
            viewforPangesture.tag = 999
            self.view.addSubview(viewforPangesture)
        }
        
        func stopCamera() {
            
            let layer = CALayer()
            layer.frame = self.previewLayer!.frame
            
            self.viewCurveCamera.layer.sublayers?.append(layer)
            
            let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
            colourAnim.fromValue = UIColor.clear.cgColor
            colourAnim.toValue = UIColor.CurveBackgroundLiteYellow.cgColor
            colourAnim.duration = ANIMATION_TIME
            layer.add(colourAnim, forKey: "colourAnimation")
            layer.backgroundColor = UIColor.CurveBackgroundLiteYellow.cgColor
            
            captureSession.stopRunning()
            for v in self.view.subviews{
                if(v.tag == 999){
                    v.removeFromSuperview()
                }
            }
            
            UIView.animate(withDuration: ANIMATION_TIME, animations: {
                self.previewLayer?.removeFromSuperlayer()
                layer.removeFromSuperlayer()
                self.buttonCamera.alpha = 1
                self.buttonDownArrow.alpha = 1.0
                self.constraintCurveViewTop.constant = self.startingConstant
                self.constraintCurveHeight.constant = self.CURVE_HEIGHT
            })
        }
        
        func loadLabelData(result: Result){
            self.labelTillKonto.text = result.accountText
            self.labelDatum.text = result.dateText
            self.labelBeloppTitle.text = "\(result.amountText) kr"
            self.labelMaddelandeTitle.text = result.referenceText
            self.buttonKlar.isEnabled = true
        }
        
        func clearLabelData(){
            self.labelTillKonto.text = self.labelTillKontoTitle.text
            self.labelDatum.text = "Belopp"
        }
        
       
        
        
        /* func captureOutput(
         _ output: AVCaptureOutput,
         didDrop sampleBuffer: CMSampleBuffer,
         from connection: AVCaptureConnection) {
         
         var mode: CMAttachmentMode = 0
         let reason = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_DroppedFrameReason, attachmentModeOut: &mode)
         
         print("Did drop sample buffer. Reason \(String(describing: reason))")
         }*/
        
        // MARK: - Callback events
        
    }
