//
//  Income.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/15/22.
//

import Foundation
import CloudKit

struct incomeStrings {
    static let recordTypeKey = "Income"
    static let incomeKey = "income"
    static let dateKey = "date"
}

class Income {
    var income: Double
    var recordID: CKRecord.ID
    var date: Date
    
    init(income: Double, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), date: Date = Date()) {
        self.income = income
        self.recordID = recordID
        self.date = date
    }
} //End of class

extension Income {
    convenience init?(ckRecord: CKRecord) {
        guard let income = ckRecord[incomeStrings.incomeKey] as? Double,
              let date = ckRecord[incomeStrings.dateKey] as? Date
        else { return nil }
        
        self.init(income: income, recordID: ckRecord.recordID, date: date)
    }
} // End of extension

extension CKRecord {
    convenience init(income: Income) {
        self.init(recordType: incomeStrings.recordTypeKey, recordID: income.recordID)
        self.setValuesForKeys([
            incomeStrings.incomeKey : income.income,
            incomeStrings.dateKey : income.date
        ])
    }
} // End of extension
