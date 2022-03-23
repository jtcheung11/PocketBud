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
    func addExpense(business: String, category: String, amount: Double, completion: @escaping(Bool) -> Void) {
        
        var needsUpdated = false
        var categoryTotal: CategoryTotal?
        var categoryTotalReference: CKRecord.Reference?
        
        let group = DispatchGroup()
        
        group.enter()
        if let currentCategoryTotal = CategoryTotalController.shared.categoryTotals.first(where: { $0.categoryName == category  }) {
            categoryTotal = currentCategoryTotal
            categoryTotalReference = CKRecord.Reference(recordID: currentCategoryTotal.recordID, action: .none)
            needsUpdated = true
            group.leave()
        } else {
            CategoryTotalController.shared.createCategoryTotal(categoryName: category, total: amount) { result in
                switch result {
                case .success(let newCategoryTotal):
                    categoryTotal = newCategoryTotal
                    categoryTotalReference = CKRecord.Reference(recordID: newCategoryTotal.recordID, action: .none)
                    group.leave()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return completion(false)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let categoryTotalReference = categoryTotalReference else { return completion(false) }
            let newExpense = Expense(business: business, category: category, amount: amount, categoryTotalReference: categoryTotalReference)
            let expenseRecord = CKRecord(expense: newExpense)
            self?.privateDB.save(expenseRecord) { (record, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let record = record,
                      let savedExpense = Expense(ckRecord: record)
                else { return completion(false)}
                
                print("Saved Expense Successfully")
                self?.expenses.insert(savedExpense, at: 0)
                
                guard let categoryTotal = categoryTotal else { return completion(false)}
                
                if needsUpdated {
                    CategoryTotalController.shared.updateCategoryTotal(categoryTotal, total: amount, completion: completion)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func fetchExpenses(for date: Date, completion: @escaping(Bool) -> Void) {
        
        let date = Calendar.current.date(byAdding: .month, value: -1, to: date) ?? Date()
        let startDate = Calendar.current.date(bySetting: .day, value: 1, of: date) ?? Date()
        let start = Calendar.current.startOfDay(for: startDate)
        
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? Date()
        
        let predicate1 = NSPredicate(format: "%K >= %@", argumentArray: [ExpenseStrings.dateKey, start])
        let predicate2 = NSPredicate(format: "%K < %@", argumentArray: [ExpenseStrings.dateKey, end])
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        let query = CKQuery(recordType: ExpenseStrings.recordTypeKey, predicate: compoundPredicate)
        var operation = CKQueryOperation(query: query)
        expenses = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedExpense = Expense(ckRecord: record)
                else { return completion(false)}
                self.expenses.append(fetchedExpense)
                
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
    
    func updateExpense(_ expense: Expense, category: String,  amount: Double, business: String ,completion: @escaping(Bool)-> Void) {
        
        var oldCategory: String?
        var oldAmount: Double?
        
        if expense.category != category {
            oldCategory = expense.category
        }
        
        if expense.amount != amount {
            oldAmount = expense.amount
        }
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
                if let oldCategory = oldCategory, let oldAmount = oldAmount {
                    CategoryTotalController.shared.updateBothCategoryTotals(oldCategory: oldCategory, newCategory: category, oldAmount: oldAmount, newAmount: amount, completion: completion)
                } else if let oldCategory = oldCategory {
                    CategoryTotalController.shared.updatCategoryTotalWithNewExpenseCategory(oldCategory: oldCategory, newCategory: category, amount: amount, completion: completion)
                } else if let oldAmount = oldAmount {
                    CategoryTotalController.shared.updateCategoryTotalWithNewAmount(category: category, oldAmount: oldAmount, newAmount: amount, completion: completion)
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
    
    func deleteExpense(_ expense: Expense, completion: @escaping (Bool) -> Void ) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [expense.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                if let index = self.expenses.firstIndex(of: expense) {
                    self.expenses.remove(at: index)
                }
                CategoryTotalController.shared.updateWhenExpenseDeleted(category: expense.category, total: expense.amount, completion: completion)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
}//End of class

