//
//  Expense.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import Foundation
import CloudKit

struct ExpenseStrings{
    static let recordTypeKey = "Expense"
    static let businessKey = "business"
    static let categoryKey = "category"
    static let amountKey = "amount"
    static let dateKey = "date"
    static let categoryTotalReferenceKey = "categoryTotalReference"
}

class Expense {
    
    var business: String
    var category: String
    var amount: Double
    var date: Date
    var categoryTotalReference: CKRecord.Reference
    var recordID : CKRecord.ID
    
    init(business: String, category: String, amount: Double, date: Date = Date(), categoryTotalReference: CKRecord.Reference, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.business = business
        self.category = category
        self.amount = amount
        self.date = date
        self.categoryTotalReference = categoryTotalReference
        self.recordID = recordID
    }
}//End of class

extension Expense {
    convenience init?(ckRecord: CKRecord){
    guard let business = ckRecord[ExpenseStrings.businessKey] as? String,
          let category = ckRecord[ExpenseStrings.categoryKey] as? String,
          let amount = ckRecord[ExpenseStrings.amountKey] as? Double,
          let date = ckRecord[ExpenseStrings.dateKey] as? Date,
          let categoryTotalReference = ckRecord[ExpenseStrings.categoryTotalReferenceKey] as? CKRecord.Reference
        else { return nil }
        
        self.init(business: business, category: category, amount: amount, date: date, categoryTotalReference: categoryTotalReference, recordID: ckRecord.recordID)
    }
} // End of extension

extension CKRecord{
    convenience init(expense: Expense) {
        //Do I need a record ID here?
        self.init(recordType: ExpenseStrings.recordTypeKey, recordID: expense.recordID)
        self.setValuesForKeys([
            ExpenseStrings.businessKey : expense.business,
            ExpenseStrings.categoryKey : expense.category,
            ExpenseStrings.amountKey : expense.amount,
            ExpenseStrings.dateKey : expense.date,
            ExpenseStrings.categoryTotalReferenceKey : expense.categoryTotalReference,
        ])
    }
} // End of extension

extension Expense: Equatable {
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
