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
    
    func updateCategoryTotal(categoryName: String, total: Double, budgetReference: CKRecord.Reference ) {
        
    }
    
}//End of class
