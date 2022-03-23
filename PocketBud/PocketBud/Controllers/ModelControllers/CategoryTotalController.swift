//
//  CategoryTotalController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/8/22.
//

import Foundation
import CloudKit

class CategoryTotalController {
    
    static let shared = CategoryTotalController()
    var categoryTotals: [CategoryTotal] = []
    let privateDB = CKContainer.default().privateCloudDatabase
    
    
    /**
     Creates a new CategoryTotal when the user picks a category that does not have any other expenses in it.
     
     - Parameter date: categoryName: The category picked by the user, total: the amount input by the user, completion: @escaping (Result<CategoryTotal, NetworkError>) -> Void
     
     -  Throws:  'ckError'
     */
    func createCategoryTotal(categoryName: String, total: Double, completion: @escaping (Result<CategoryTotal, NetworkError>) -> Void) {
        let components = Calendar.current.dateComponents([.month , .year], from: Date())
        
        guard let month = components.month,
              let year = components.year else { return completion(.failure(.foundNil)) }
        
        let newCategoryTotal = CategoryTotal(categoryName: categoryName, total: total, month: month, year: year)
        let categoryTotalRecord = CKRecord(categoryTotal: newCategoryTotal)
        privateDB.save(categoryTotalRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            guard let record = record,
                  let savedCategoryTotal = CategoryTotal(ckRecord: record)
            else { return completion(.failure(.noData))}
            
            print("Saved CategoryTotal Successfully")
            self.categoryTotals.insert(savedCategoryTotal, at: 0)
            completion(.success(savedCategoryTotal))
        }
    }
    
    /**
     fetches all Category Totals from the cloud based on the month the user is in.
     
     - Parameter date: the date of teh fetched catagory totals
     
     */
    func fetchCategoryTotals(date: Date, completion: @escaping(Bool)-> Void) {
        let components = Calendar.current.dateComponents([.month , .year], from: date)
        
        guard let month = components.month,
              let year = components.year else { return completion(false) }
        
        let monthPredicate = NSPredicate(format: "%K == %@", argumentArray: [CategoryTotalStrings.monthKey, month])
        let yearPredicate = NSPredicate(format: "%K == %@", argumentArray: [CategoryTotalStrings.yearKey, year])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
        
        let query = CKQuery(recordType: CategoryTotalStrings.recordTypeKey, predicate: compoundPredicate)
        var operation = CKQueryOperation(query: query)
        
        var fetchedCategoryTotals: [CategoryTotal] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedCategoryTotal = CategoryTotal(ckRecord: record)
                else { return completion(false)}
                fetchedCategoryTotals.append(fetchedCategoryTotal)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
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
                    self.categoryTotals = fetchedCategoryTotals
                    return completion(true)
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
    
    /**
     Updates a Category Total when user adds a new expense via the "+" button
     
     - Parameter categoryTotal: The CategoryTotal that is selected by the user,  total: All the expenses that are in the Category selected, completion:
     
     */
    func updateCategoryTotal(_ categoryTotal: CategoryTotal, total: Double, completion: @escaping(Bool) -> Void ) {
        categoryTotal.total += total
        
        let record = CKRecord(categoryTotal: categoryTotal)
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
    
    /**
     Updates a Category Total when a new Category is picked by the user
     
     - Parameter oldCategory: Category Selected Previously by user, newCategory: Different category selected by user, amount: Amount input by user should NOT change , completion
     
     */
    func updatCategoryTotalWithNewExpenseCategory(oldCategory: String, newCategory: String, amount: Double, completion: @escaping (Bool) -> Void) {
        guard let oldCategoryTotal = categoryTotals.first(where: { $0.categoryName == oldCategory }) else { return completion(false) }
        let group = DispatchGroup()
        
        group.enter()
        updateCategoryTotal(oldCategoryTotal, total: -amount) { success in
            if success {
                group.leave()
            } else {
                return completion(false)
            }
        }
        group.enter()
        if let newCategoryTotal = categoryTotals.first(where: { $0.categoryName == newCategory }) {
            updateCategoryTotal(newCategoryTotal, total: amount) { success in
                if success {
                    group.leave()
                } else {
                    return completion(false)
                }
            }
            
        } else {
            createCategoryTotal(categoryName: newCategory, total: amount) { result in
                switch result {
                case .success(_):
                    group.leave()
                case .failure(_):
                    return completion(false)
                }
            }
        }
        group.notify(queue: .main) {
            return completion(true)
        }
    }
    
    /**
     Updates a CategoryTotal when the amount in the CategoryTotal is altered/updated by the user
     
     - Parameter date: category: original Category picked by the user, oldAmount: The old amount the user input , newAmount: The new amount the user input, completion:
     
     */
    func updateCategoryTotalWithNewAmount(category: String, oldAmount: Double, newAmount: Double, completion: @escaping(Bool)-> Void) {
        guard let category = categoryTotals.first(where: { $0.categoryName == category }) else { return completion(false)}
        let differenceAmount = newAmount - oldAmount
        updateCategoryTotal(category, total: differenceAmount) { success in
            return completion(true)
        }
    }
    
    /**
     Updates a CategoryTotal when the amount in the CategoryTotal is altered/updated  and when a new Cateogry is picked by the user
     
     - Parameter date: category: original Category picked by the user, newCategory: the new Category picked by the user , oldAmount: The old amount the user input , newAmount: The new amount the user input, completion:
     
     */
    func updateBothCategoryTotals(oldCategory: String, newCategory: String, oldAmount: Double, newAmount: Double, completion: @escaping(Bool) -> Void) {
        
        guard let oldCategoryTotal = categoryTotals.first(where: { $0.categoryName == oldCategory }) else { return completion(false)}
        let group = DispatchGroup()
        group.enter()
        updateCategoryTotal(oldCategoryTotal, total: -oldAmount) { success in
            if success {
                group.leave()
            } else {
                return completion(false)
            }
        }
        group.enter()
        if let newCategoryTotal = categoryTotals.first(where: { $0.categoryName == newCategory }) {
            updateCategoryTotal(newCategoryTotal, total: newAmount) { success in
                if success {
                    group.leave()
                } else {
                    return completion(false)
                }
            }
        } else {
            createCategoryTotal(categoryName: newCategory, total: newAmount) { success in
                switch success {
                case .success(_):
                    group.leave()
                case .failure(_):
                    return completion(false)
                }
            }
        }
        group.notify(queue: .main) {
            return completion(true)
        }
    }
    
    /**
     Updates a CategoryTotal when the user deletes an expense
     
     - Parameter category: category picked by user, total: input by user, completion:
     
     */
    func updateWhenExpenseDeleted(category: String, total: Double, completion: @escaping(Bool) -> Void) {
        // Step 1 - get categoryTotal
        guard let categoryTotal = categoryTotals.first(where: { $0.categoryName == category }) else
        { return completion(false) }
        // Step 2a -if categoryTotal.amount  == amount { } if true delete categoryTotal
        if categoryTotal.total == total {
            deleteCategoryTotal(categoryTotal: categoryTotal, completion: completion)
        } else {
            updateCategoryTotal(categoryTotal, total: -total, completion: completion)
            // Step 2b - else call update function with the -amount
        }
    }
    
    func deleteCategoryTotal(categoryTotal: CategoryTotal, completion: @escaping(Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [categoryTotal.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                if let index = self.categoryTotals.firstIndex(of: categoryTotal) {
                    self.categoryTotals.remove(at: index)
                }
                return completion(true)
            case .failure(_):
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
}//End of class
