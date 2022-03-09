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
        guard let currentBudget = BudgetController.shared.currentBudget else { return completion(.failure(.foundNil)) }
        
        let budgetReference = CKRecord.Reference(recordID: currentBudget.recordID, action: .none)
        
        let newCategoryTotal = CategoryTotal(categoryName: categoryName, total: total, budgetReference: budgetReference)
        let categoryTotalRecord = CKRecord(categoryTotal: newCategoryTotal)
        privateDB.save(categoryTotalRecord) { (record, error) in
            //Do I need error above? ^ if not what do I do below? just return compeltion?
            if let error = error {
                return completion(.failure(.unableToSave))
            }
            guard let record = record,
                  let savedCategoryTotal = CategoryTotal(ckRecord: record)
            else { return completion(.failure(.noData))}
            
            print("Saved CategoryTotal Successfully")
            self.categoryTotals.insert(savedCategoryTotal, at: 0)
            completion(.success(savedCategoryTotal))
        }
        
    }
    
    func updateCategoryTotal(_ categoryTotal: CategoryTotal, categoryName: String, total: Double, budgetReference: CKRecord.Reference, completion: @escaping(Bool) -> Void ) {
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
    
    
    //Func 1: create an expense with a Category and attempt to create a new CategoryTotal. If that CategoryTotal already exists then fetch CategoryTotal and update it.
    
    //Func 2: When Amount is updated call this func to update the CategoryTotal by the changed amount
    
    //Func 3: When the Category is updated to a different or new CategoryTotal update the selected category>> CategoryTotal and create a new CategoryTotal if it does not exists.
    
}//End of class
