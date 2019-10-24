//
//  ExtString.swift
//  FakturaSanning
//
//  Created by MacBook on 20/9/19.
//  Copyright © 2019 Nicknamed. All rights reserved.
//

import UIKit

extension String {
    func getText()->String {
        let arra = self.components(separatedBy: ["(", ")", ":",","]).filter({!$0.isEmpty})
        return arra[2]
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}
