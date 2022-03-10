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
    static let recordIDKey = "recordID"
    static let monthKey = "month"
    static let yearKey = "year"
}

class CategoryTotal {
    
    var categoryName: String
    var total: Double
    var recordID : CKRecord.ID
    var month : Int
    var year : Int
    
    init(categoryName: String, total: Double, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), month: Int, year: Int){
        self.categoryName = categoryName
        self.total = total
        self.recordID = recordID
        self.month = month
        self.year = year
    }
    
} //End of class

extension CategoryTotal {
    convenience init?(ckRecord: CKRecord) {
        guard let categoryName = ckRecord[CategoryTotalStrings.categoryNameKey] as? String,
        let total = ckRecord[CategoryTotalStrings.totalKey] as? Double,
        let recordID = ckRecord[CategoryTotalStrings.recordIDKey] as? CKRecord.ID,
        let month = ckRecord[CategoryTotalStrings.monthKey] as? Int,
        let year = ckRecord[CategoryTotalStrings.yearKey] as? Int
        else { return nil }
        
        self.init(categoryName: categoryName, total: total, recordID: recordID, month: month, year: year)
    }
} // End of extension

extension CKRecord {
    convenience init(categoryTotal: CategoryTotal) {
        self.init(recordType: "CategoryTotal", recordID: categoryTotal.recordID)
        self.setValuesForKeys([
            CategoryTotalStrings.categoryNameKey : categoryTotal.categoryName,
            CategoryTotalStrings.totalKey : categoryTotal.total,
            CategoryTotalStrings.recordIDKey : categoryTotal.recordID,
            CategoryTotalStrings.monthKey : categoryTotal.month,
            CategoryTotalStrings.yearKey : categoryTotal.year
        ])
    }
} // End of extension

