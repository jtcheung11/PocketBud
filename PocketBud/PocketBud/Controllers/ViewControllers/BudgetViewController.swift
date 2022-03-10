//
//  BudgetViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/9/22.
//

import UIKit

class BudgetViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var incomeAndCateogryTotalsView: UIView!
    @IBOutlet weak var categoryTotalTBCell: UITableViewCell!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var currentTotalSpentLabel: UILabel!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    //MARK: - Properties
    
    
    //MARK: - Data Source Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewCornersRounded()
        
    }
    
    //MARK: - Helper Methods
    
    private func viewCornersRounded() {
        progressBarView.layer.cornerRadius = 16
        incomeAndCateogryTotalsView.layer.cornerRadius = 16
    }
    
    @IBAction func updateIncomeButtonTapped(_ sender: UIButton) {
        
    }
    
    
    // MARK: - Navigation

    // Do I even need this?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExpenseDetailDV" {
//            guard let indexPath = tableView.indexPathForSelectedRow
           guard let destinationVC = segue.destination as? ExpenseDetailViewController else { return }
            let expensesToSend = ExpenseController.shared.expense
            destinationVC.expenses = expensesToSend
        }
    }
    

}
