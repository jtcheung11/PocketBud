//
//  IncomeController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/15/22.
//

import Foundation
import CloudKit

class IncomeController {
    static let shared = IncomeController()
    var income: [Income] = []
    let privateDB = CKContainer.default().privateCloudDatabase
    
    
    //CRUD
    func createIncome(income: Double, completion: @escaping(Bool) -> Void) {
        /*
         let components = Calendar.current.dateComponents([.month , .year], from: Date())
         guard let month = components.month,
         let year = components.year else { return completion(.failure(.foundNil)) }
         */
        let newIncome = Income(income: income)
        let record = CKRecord(income: newIncome)
        self.privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
    }
    
    
    func fetchIncome(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: incomeStrings.incomeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        
        operation.recordMatchedBlock = { (_, result ) in
            switch result {
            case .success(let record):
                guard let fetchedIncome = Income(ckRecord: record)
                else { return completion(false) }
                self.income.append(fetchedIncome)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
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
                } else { return completion(true) }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            
        }
        
    }
    
    func updateIncome(_ income: Income, completion: @escaping(Bool) -> Void) {
        let record = CKRecord(income: income)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result{
            case .success():
                return completion(true)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
} //End of class
