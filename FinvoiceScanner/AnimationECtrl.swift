//
//  AnimationECtrl.swift
//  FinvoiceScanner
//
//  Created by Chamath Jeevnan on 14/10/19.
//  Copyright © 2019 Nicknamed. All rights reserved.
//

import UIKit

extension ViewController {
    
    @objc internal func viewDidDrag(_ sender: UIPanGestureRecognizer) {
          
          let translation = sender.translation(in: self.view).y
          
          if(translation == 0){
              return
          }
          
          switch sender.state {
          case .began:
              isPanGestureCompleted = false
          case .changed:
              self.constraintCurveViewTop.constant = getConstraint(translation: translation)
          case .ended:
              getEndingAnimation();
          default:
              break
          }
      }
    
    func getEndingAnimation(){
        
        UIView.animate(withDuration: ANIMATION_TIME, animations: {
            
            self.constraintCurveViewTop.constant = self.getEndConstraint()
            
            self.constraintCurveHeight.constant = self.CURVE_HEIGHT
            
            self.view.layoutIfNeeded()
            
        }) { (result) in
            
            if(self.constraintCurveViewTop.constant == 0){
                self.openCameraView()
            }else{
                self.closeCameraView()
            }
            self.isPanGestureCompleted = true
        }
    }
    
    
    func getConstraint(translation:CGFloat)->(CGFloat){
        
        var constraint:CGFloat = 0.0
        if (translation > 0){
            if(self.constraintCurveViewTop.constant >= 0) {
                constraint = translation
            }else{
                constraint = (self.startingConstant) + (translation)
            }
        }else if(translation < 0){
            
            if(self.constraintCurveViewTop.constant <= startingConstant) {
                constraint = (self.startingConstant) + (translation)
            }else{
                constraint = translation
            }
        }
        
        if(constraint > 0){
            constraint = 0
        }
        
        return constraint
    }
    
    func getEndConstraint()->(CGFloat){
        
        let HALF_AREA =  (CURVE_HEIGHT) * 0.6
        let VISIBLE_AREA = (CURVE_HEIGHT)  + (self.constraintCurveViewTop.constant)
        
        print("CURVE_HEIGHT : \(CURVE_HEIGHT) TOP : \(self.constraintCurveViewTop.constant)  VISIBLE : \(VISIBLE_AREA)")
        
        if( VISIBLE_AREA > HALF_AREA) {
            return 0
        }else{
            return  self.startingConstant
        }
    }
}
