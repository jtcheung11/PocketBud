//
//  ConvertToDollarHelper.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/14/22.
//

import Foundation
class ConvertToDollar {
    static let shared = ConvertToDollar()
    
    func toDollar(value: Double) -> String {
        return "$" + String(format: "%.2f", value)
    }
}
