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
            updateView()
        }
    }
    
    
    func updateView(){
        guard let expense = expense else { return }
        businessNameLabel.text = expense.business
        amountLabel.text = String(expense.amount)
        //TODO: how to set date on dateLabel
        
        
    
        
    }
    
    
    
} //End of class

/*
 func updateViews() {
     guard let expense = expense else { return }
     businessNameLabel.text = expense.title
     if event.isComplete {
         clockButton.setImage(UIImage(systemName: "clock"), for: .normal)
     } else {
         clockButton.setImage(UIImage(systemName: "clock.fill"), for: .normal)
     }
 }
 */
