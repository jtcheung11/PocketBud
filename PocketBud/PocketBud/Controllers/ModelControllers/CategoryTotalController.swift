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
    
    func updateCategoryTotal(_ categoryTotal: CategoryTotal, total: Double, completion: @escaping(Bool) -> Void ) {
        categoryTotal.total += total
        
        let record = CKRecord(categoryTotal: categoryTotal)
        ///Do I need 'recordIDsToDelete to actually delete if the updated category was the only expense in that category?
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
    
    func updatCategoryTotalWithNewExpenseCategory(oldCategory: String, newCategory: String, amount: Double, completion: @escaping (Bool) -> Void) {
        // Step 1 - get oldCategoryTotal
        guard let oldCategoryTotal = categoryTotals.first(where: { $0.categoryName == oldCategory }) else { return completion(false) }
        let group = DispatchGroup()
        // Step 3 - subtract amount from oldCategoryTotal and update
        group.enter()
        updateCategoryTotal(oldCategoryTotal, total: -amount) { success in
            if success {
                group.leave()
            } else {
                return completion(false)
            }
        }
        // Step 2 - get or create newCategoryTotal
        // Step 4 - add amount to newCategoryTotal and update
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
        // Step 5 - Dispatch Group
        group.notify(queue: .main) {
            return completion(true)
        }
    }
    
    func updateCategoryTotalWithNewAmount(category: String, oldAmount: Double, newAmount: Double, completion: @escaping(Bool)-> Void) {
        // Step 1 - get categoryTotal
        guard let category = categoryTotals.first(where: { $0.categoryName == category }) else { return completion(false)}
        // Step 2 - add or subtract amount from categoryTotal.total
        let differenceAmount = newAmount - oldAmount
        // Step 3 - update categoryTotal
        updateCategoryTotal(category, total: differenceAmount) { success in
            return completion(true)
        }
    }
    
    func updateBothCategoryTotals(oldCategory: String, newCategory: String, oldAmount: Double, newAmount: Double, completion: @escaping(Bool) -> Void) {
        // Step 1 - get oldCategoryTotal
        // Step 3 - subtract oldAmount from oldCategoryTotal and update
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
        // Step 2 - get or create newCategoryTotal
        // Step 4 - add newAmount to newCategoryTotal and update
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
        // Step 5 - Dispath Group
        group.notify(queue: .main) {
            return completion(true)
        }
    }
    
}//End of class
