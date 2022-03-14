//
//  ExpenseDetailTableViewCell.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/8/22.
//

import UIKit
import CloudKit

class ExpenseDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    let currentDate = Date()
    
    var expense: Expense? {
        didSet {
            updateViews(with: expense)
        }
    }
        
    func updateViews(with expense: Expense?){
//        guard let expense = expense else { return }
//        businessNameLabel.text = expense.business
//        amountLabel.text = String(expense.amount)
//        dateLabel.text = currentDate.stringValue()
    }
    

    
} //End of class
