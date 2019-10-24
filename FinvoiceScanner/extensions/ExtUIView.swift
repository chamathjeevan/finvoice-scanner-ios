//
//  UIViewCurve.swift
//  FakturaSanning
//
//  Created by MacBook on 16/9/19.
//  Copyright © 2019 Nicknamed. All rights reserved.
//

import UIKit

extension UIView {

    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = true
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 2
        layer.borderWidth = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        layer.borderColor =  UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
   }
    
    func addBottomRoundedEdge() {
        let offset: CGFloat = (self.frame.width * 1.5)
        let bounds: CGRect = self.bounds
        
        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width , height: bounds.size.height / 2)
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset , height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)

        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        layer.shadowPath = UIBezierPath(rect: maskLayer.bounds).cgPath
        layer.shadowRadius = 5
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1
        
        self.layer.mask = maskLayer
    }
    
}
