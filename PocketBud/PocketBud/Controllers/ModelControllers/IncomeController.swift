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
    let privateDB = CKContainer.default().privateCloudDatabase
    var currentIncome: Income?
    
    //CRUD
    func createIncome(income: Double, completion: @escaping(Bool) -> Void) {
        let newIncome = Income(income: income)
        let record = CKRecord(income: newIncome)
        self.privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            guard let record = record,
                  let savedIncome = Income(ckRecord: record)
            else { return completion(false) }
            self.currentIncome = savedIncome
            return completion(true)
        }
    }
    
    
    func fetchIncome(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: incomeStrings.recordTypeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        var fetchedIncomes: [Income] = []
        
        operation.recordMatchedBlock = { (_, result ) in
            switch result {
            case .success(let record):
                guard let fetchedIncome = Income(ckRecord: record)
                else { return completion(false) }
                fetchedIncomes.append(fetchedIncome)
                print(fetchedIncome.income)
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
                } else {
                    fetchedIncomes.sort(by: { $0.date > $1.date })
                    self.currentIncome = fetchedIncomes.first
                    return completion(true)
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        privateDB.add(operation)
    }
    
    func updateIncome(_ income: Income, newIncome : Double, completion: @escaping(Bool) -> Void) {
        income.income = newIncome
        income.date = Date()
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
