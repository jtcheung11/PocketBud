//
//  CategoryTotal.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import Foundation
import CloudKit

struct CategoryTotalStrings {
    static let recordTypeKey = "CategoryTotal"
    static let categoryNameKey = "categoryName"
    static let totalKey = "total"
    static let budgetReferenceKey = "budgetReference"
    static let recordIDKey = "recordID"
}

class CategoryTotal {
    
    var categoryName: String
    var total: Double
    var budgetReference: CKRecord.Reference?
    var recordID : CKRecord.ID
    
    init(categoryName: String, total: Double, budgetReference: CKRecord.Reference?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.categoryName = categoryName
        self.total = total
        self.budgetReference = budgetReference
        self.recordID = recordID
    }
    
} //End of class

extension CategoryTotal {
    convenience init?(ckRecord: CKRecord) {
        guard let categoryName = ckRecord[CategoryTotalStrings.categoryNameKey] as? String,
        let total = ckRecord[CategoryTotalStrings.totalKey] as? Double,
        let budgetReference = ckRecord[CategoryTotalStrings.budgetReferenceKey] as? CKRecord.Reference,
        let recordID = ckRecord[CategoryTotalStrings.recordIDKey] as? CKRecord.ID
        else { return nil }
        
        self.init(categoryName: categoryName, total: total, budgetReference: budgetReference, recordID: recordID)
    }
} // End of extension

extension CKRecord {
    convenience init(categoryTotal: CategoryTotal) {
        self.init(recordType: "CategoryTotal")
        self.setValuesForKeys([
            CategoryTotalStrings.categoryNameKey : categoryTotal.categoryName,
            CategoryTotalStrings.totalKey : categoryTotal.total,
            //Expression implicitly coerced from 'CKRecord.Reference?' to 'Any'
            CategoryTotalStrings.budgetReferenceKey: categoryTotal.budgetReference,
            CategoryTotalStrings.recordIDKey: categoryTotal.recordID
        ])
    }
} // End of extension

