//
//  Analysis.swift
//  FakturaSanning
//
//  Created by MacBook on 23/9/19.
//  Copyright © 2019 Nicknamed. All rights reserved.
//

import UIKit
import Finvoice

class Analysis: NSObject {
    static var result = Result()
    
    static var accountIsSuccess: Bool = false
    static var referenceIsSuccess: Bool = false
    static var amountIsSuccess: Bool = false
    static var dateIsSuccess: Bool = false
    
    static func analized(scanningResult:InvoiceScanningResult)->(Bool){
        
        var ratio = 0;
        Analysis.result.accountText = scanningResult.accountText()
        Analysis.result.accountPrediction = scanningResult.accountPredict()
        
        Analysis.result.referenceText = scanningResult.referenceText()
        Analysis.result.referencePrediction = scanningResult.referencePredict()
        
        Analysis.result.amountText = scanningResult.amountText()
        Analysis.result.amountPrediction = scanningResult.amountPredict()
        
        Analysis.result.dateText = scanningResult.dateText()
        Analysis.result.datePrediction = scanningResult.datePredict()
        
        print("\(Analysis.result.accountPrediction) - \(Analysis.result.referencePrediction) - \(Analysis.result.amountPrediction) - \( Analysis.result.datePrediction )")
        
        
        if (Analysis.result.accountPrediction > 0.8){
            ratio += 1
        }
        
        if(Analysis.result.referencePrediction > 0.8){
             ratio += 1
        }
        
        if(Analysis.result.amountPrediction > 0.8){
             ratio += 1
        }
        
        if(Analysis.result.datePrediction > 0.8){
             ratio += 1
        }
     
        if( ratio > 2){
            return true
        }
        
        return false
        
    }
    
    static func isResultReady()->(Bool){
        if accountIsSuccess &&  referenceIsSuccess && amountIsSuccess && dateIsSuccess {
            return true
        }else {
            return false
        }
    }
    
    static func reset(){
        accountIsSuccess  = false
        referenceIsSuccess  = false
        amountIsSuccess  = false
        dateIsSuccess  = false
        result.accountText = ""
        result.accountPrediction = 0.00
        result.referenceText = ""
        result.referencePrediction = 0.00
        result.amountText = ""
        result.amountPrediction = 0.00
        result.dateText = ""
        result.datePrediction = 0.00
    }
}


extension  InvoiceScanningResult {
    func accountText()->String{
        return getText(text: "\(self.accountPrediction)")
    }
    
    func accountPredict()->Double {
        return getPredict( text: "\(self.accountPrediction)")
    }
    
    func referenceText()->String{
        return getText(text: "\(self.referencePrediction)")
    }
    
    func referencePredict()->Double {
        return getPredict( text: "\(self.referencePrediction)")
    }
    
    func amountText()->String{
        return getText( text: "\(self.amountPrediction)")
    }
    
    func amountPredict()->Double {
        return getPredict( text: "\(self.amountPrediction)")
    }
    
    func dateText()->String{
        return getText( text: "\(self.datePrediction)")
    }
    
    func datePredict()->Double {
        return getPredict( text: "\(self.datePrediction)")
    }
    
    func getPredict(text:String)->Double {
        let array = toArray(text: text)
        return (array[1] as NSString).doubleValue
    }
    
    func getText(text:String)->String {
        let array = toArray(text: text)
        print("DC \(array) | --> \(array[0])")
        return array[0]
    }
    
    func toArray(text:String) -> [String]{
        let purifiedText = text.replacingOccurrences(of: "Prediction(text:", with: "").replacingOccurrences(of: ", probability: ", with: "|").replacingOccurrences(of: ")", with: "")
        print(purifiedText)
        let array = purifiedText.components(separatedBy: ["|", ")"]).filter({!$0.isEmpty})
        return array
    }
}

