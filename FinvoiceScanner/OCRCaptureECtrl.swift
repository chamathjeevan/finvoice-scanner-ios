//
//  OCRCaptureECtrl.swift
//  FinvoiceScanner
//
//  Created by Chamath Jeevan on 14/10/19.
//  Copyright © 2019 Nicknamed. All rights reserved.
//

import UIKit
import AVFoundation
import Finvoice

extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
        if isPanGestureCompleted {
            
            let page = InvoicePage(sampleBuffer: sampleBuffer,imageOrientation: getCameraOrientation())
            
            bufferedPages.insert(page)
            self.numberOfScans += 1
            if(self.numberOfScans > 8){
                analiseOCRBatch(pages: bufferedPages)
            }
        }
    }
    
    func analiseOCRBatch(pages :Set<InvoicePage>){
        self.invoiceScanner.scan(pages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let predictions):
                    print("\(predictions)")
                    if(Analysis.analized(scanningResult: predictions)){
                        self.loadLabelData(result: Analysis.result)
                        self.closeCameraView()
                        AudioServicesPlaySystemSound(1016)
                    }
                    break
                case .failure:
                    self.numberOfScans = 0
                    self.bufferedPages.removeAll()
                    break
                }
            }
        }
    }
    
    func getCameraOrientation()->(CGImagePropertyOrientation){
        
        let cameraPosition = captureDevice.position
        let imageOrientation: CGImagePropertyOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            imageOrientation = cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            imageOrientation = cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            imageOrientation = cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            imageOrientation = cameraPosition == .front ? .upMirrored : .down
        default:
            imageOrientation = cameraPosition == .front ? .leftMirrored : .right
        }
        return imageOrientation
    }
}
