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
    
//    weak var delegate:
    var expense: Expense? {
        didSet {
            updateViews(with: expense)
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expenseToDelete = ExpenseController.shared.expense[indexPath.row]
            guard let index = ExpenseController.shared.expense.firstIndex(of: expenseToDelete)
            else { return }
            
            ExpenseController.shared.deleteExpense(expenseToDelete) { (success) in
                if success {
                    ExpenseController.shared.expense.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    func updateViews(with expense: Expense?){
        guard let expense = expense else { return }
        businessNameLabel.text = expense.business
        amountLabel.text = String(expense.amount)
        //TODO: how to set date on dateLabel
    }
    

    
} //End of class
