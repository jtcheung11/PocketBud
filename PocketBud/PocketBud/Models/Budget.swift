//
//  Budget.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import Foundation
import CloudKit

struct BudgetStrings {
    static let dateKey = "date"
    static let recordIDKey = "recordID"
    static let incomeKey = "income"
    static let totalKey = "total"
    
}

class Budget {
        var date: Date
        var recordID: CKRecord.ID
        var income: Double
        var total: Double
    
    init(date: Date, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), income: Double, total: Double) {
    self.date = date
    self.recordID = recordID
    self.income = income
    self.total = total
    }
}

extension Budget {
    convenience init?(ckRecord: CKRecord) {
        guard let date = ckRecord[BudgetStrings.dateKey] as? Date,
              let recordID = ckRecord[BudgetStrings.recordIDKey] as? CKRecord.ID,
              let income = ckRecord[BudgetStrings.incomeKey] as? Double,
              let total = ckRecord[BudgetStrings.totalKey] as? Double
        else { return nil }
        
        self.init(date: date, recordID: recordID, income: income, total: total)
    }
}

extension CKRecord {
    convenience init(budget: Budget) {
        self.init(recordType:"Budget")
        self.setValuesForKeys([
            BudgetStrings.dateKey : budget.date,
            BudgetStrings.recordIDKey : budget.recordID,
            BudgetStrings.incomeKey : budget.income,
            BudgetStrings.totalKey : budget.total
        ])
    }
} // End of extension
