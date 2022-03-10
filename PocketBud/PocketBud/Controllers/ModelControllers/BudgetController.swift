//
//  BudgetController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/8/22.
//

import Foundation
import CloudKit

class BudgetController {
    
    static let shared = BudgetController()
    let privateDB = CKContainer.default().privateCloudDatabase
    var currentBudget: Budget?
    //CRUD
    
    //create
    func createBudget(date: Date, income: Double, total: Double, completion: @escaping (Result<Budget, NetworkError>) -> Void) {
        let categoryTotalsAdded = CategoryTotalController.shared.categoryTotals.reduce(into: 0.0) { partialResult, categoryTotal in
            partialResult += categoryTotal.total
        }
        
        let newBudget = Budget(date: date, income: income, total: categoryTotalsAdded)
        let budgetRecord = CKRecord(budget: newBudget)
        privateDB.save(budgetRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
        guard let record = record,
                let savedBudget = Budget(ckRecord: record)
            else { return completion(.failure(.noData))}
            
            print("Saved Budget Successfully")
            self.currentBudget = savedBudget
            
        }
        
    }
    
    //fetch
    func fetchABudget(date: Date, completion: @escaping(Bool) -> Void) {
        
    }
    
    
    /*
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
     */
    
    //update
    func updateBudget(_ budget: Budget, income: Double, total: Double, completion: @escaping(Bool) -> Void) {
        budget.income = income
        budget.total = total
        
        let record = CKRecord(budget: budget)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("Updated Budget(income)")
                completion(true)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            }
        }
        privateDB.add(operation)
    }
} //End of class
