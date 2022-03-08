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
    let publicDB = CKContainer.default().publicCloudDatabase
    
//MARK - CRUD
    //Create
    func addExpense(business: String, category: String, amount: Double, date: Date = Date(), completion: @escaping(Bool) -> Void) {
       // Do I need my reference to 'categoryTotalReference' here?
//        let categoryTotalReference = CKRecord.Reference(record: , action: .none)
        let newExpense = Expense(business: business, category: category, amount: amount, date: date)
        let expenseRecord = CKRecord(expense: newExpense)
        publicDB.save(expenseRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let record = record,
                  //Does this work?
                    let savedExpense = Expense(ckRecord: record)
            else { return completion(false)}
            
            print("Saved Expense Successfully")
            self.expenses.insert(savedExpense, at: 0)
            completion(true)
        }
    }
    
    
    //Retrieve/Fetch
    func fetchExpense(completion: @escaping(Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseStrings.recordTypeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        
        var fetchedExpenses: [Expense] = []
        
        //start here when returning
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                //what is ckRecord coming from? Extension on Expense Model?
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
                    self.publicDB.add(nextOperation)
                } else {
                    return completion(true)
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        publicDB.add(operation)
    }
    
    //Update
    func updateExpense(_ expense: Expense, completion: @escaping(Bool)-> Void) {
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
        publicDB.add(operation)
    }
    
}//End of class

