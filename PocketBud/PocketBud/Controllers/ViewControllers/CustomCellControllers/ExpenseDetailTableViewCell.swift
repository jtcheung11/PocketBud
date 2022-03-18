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
    
    var expense: Expense? {
        didSet {
            updateViews()
        }
    }
        
    func updateViews() {
        guard let expense = expense else { return }
        businessNameLabel.text = expense.business
        amountLabel.text = ConvertToDollar.shared.toDollar(value: expense.amount)
        dateLabel.text = expense.date.monthDayYear()
    }
    

    
} //End of class
