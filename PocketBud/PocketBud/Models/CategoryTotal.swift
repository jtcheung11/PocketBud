//
//  CategoryTotal.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import Foundation
import CloudKit

class CategoryTotal {
    
    var categoryName: String
    var total: Double
    var budgetReference: CKRecord.Reference
    
    init(categoryName: String, total: Double, budgetReference: CKRecord.Reference){
        self.categoryName = categoryName
        self.total = total
        self.budgetReference = budgetReference
    }
    
}
