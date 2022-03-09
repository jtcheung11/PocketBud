//
//  ExpenseController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import UIKit
import CloudKit

class ExpenseController {
    
static let shared = ExpenseController()
    var expenses: [Expense] = []
    let privateDB = CKContainer.default().privateCloudDatabase
    
//MARK - CRUD
    //Create
    func addExpense(business: String, category: String, amount: Double, completion: @escaping(Bool) -> Void) {
        
        var categoryTotal: CategoryTotal?
        var categoryTotalReference: CKRecord.Reference?
        
        if let currentCategoryTotal = CategoryTotalController.shared.categoryTotals.first(where: { $0.categoryName == category  }) {
            categoryTotal = currentCategoryTotal
             categoryTotalReference = CKRecord.Reference(recordID: currentCategoryTotal.recordID, action: .none)
        } else {
            CategoryTotalController.shared.createCategoryTotal(categoryName: category, total: amount) { result in
                switch result {
                case .success(let newCategoryTotal):
                    categoryTotal = newCategoryTotal
                    categoryTotalReference = CKRecord.Reference(recordID: newCategoryTotal.recordID, action: .none)
                    // JC - Dispatch Group?
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return completion(false)
                }
            }
        }
        guard let categoryTotalReference = categoryTotalReference else { return completion(false) }
        let newExpense = Expense(business: business, category: category, amount: amount, categoryTotalReference: categoryTotalReference)
        let expenseRecord = CKRecord(expense: newExpense)
        privateDB.save(expenseRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let record = record,
                    let savedExpense = Expense(ckRecord: record)
            else { return completion(false)}
            
            print("Saved Expense Successfully")
            self.expenses.insert(savedExpense, at: 0)
            
            guard let categoryTotal = categoryTotal else { return completion(false)}

            
            CategoryTotalController.shared.updateCategoryTotal(categoryTotal, total: amount, completion: completion)
            
//            completion(true)
        }
    }
    
    
    //Retrieve/Fetch
    func fetchExpenses(completion: @escaping(Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseStrings.recordTypeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        
        var fetchedExpenses: [Expense] = []
    
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedExpense = Expense(ckRecord: record)
                else { return completion(false)}
                fetchedExpenses.append(fetchedExpense)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    operation = nextOperation
                    self.privateDB.add(nextOperation)
                } else {
                    return completion(true)
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
    
    //Update
    func updateExpense(_ expense: Expense, category: String, amount: Double, business: String ,completion: @escaping(Bool)-> Void) {
        
        expense.business = business
        expense.amount = amount
        expense.category = category
        let record = CKRecord(expense: expense)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                return completion(true)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
    
    //delete
    func deleteExpense(_ expense: Expense, completion: @escaping (Bool) -> Void ) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [expense.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                return completion(true)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
    
}//End of class

