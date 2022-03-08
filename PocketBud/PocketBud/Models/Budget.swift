//
//  Budget.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import Foundation
import CloudKit

class Budget {
        var date: Date
        var recordID: CKRecord.ID
        var income: Double
        var total: Double
    
    init(date: Date, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), income: Double, total: Double) {
    self.date = date
    self.recordID = recordID
    self.income = income
    self.total = total
    }
}
