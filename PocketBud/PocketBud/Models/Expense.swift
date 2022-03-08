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
    
    init(business: String, category: String, amount: Double, date: Date, categoryTotalReference: CKRecord.Reference) {
        
        self.business = business
        self.category = category
        self.amount = amount
        self.date = date
        self.categoryTotalReference = categoryTotalReference
    }
}//End of class

extension Expense {
    convenience init?(ckRecord: CKRecord){
    guard let business = ckRecord[ExpenseStrings.businessKey] as? String,
          let category = ckRecord[ExpenseStrings.categoryKey] as? String,
          let amount = ckRecord[ExpenseStrings.amountKey] as? Double,
          let date = ckRecord[ExpenseStrings.dateKey] as? Date
        else { return nil }
        
          let categoryTotalReference = ckRecord[ExpenseStrings.categoryTotalReferenceKey] as? CKRecord.Reference
        //Unwrapping error
        self.init(business: business, category: category, amount: amount, date: date, categoryTotalReference: categoryTotalReference)
    }
}

extension CKRecord{
    convenience init(expense: Expense) {
        //Do I need a record ID here?
        self.init(recordType: "Expense")
        self.setValuesForKeys([
            ExpenseStrings.businessKey : expense.business,
            ExpenseStrings.categoryKey : expense.category,
            ExpenseStrings.amountKey : expense.amount,
            ExpenseStrings.dateKey : expense.date,
            ExpenseStrings.categoryTotalReferenceKey : expense.categoryTotalReference
        ])
    }
}
