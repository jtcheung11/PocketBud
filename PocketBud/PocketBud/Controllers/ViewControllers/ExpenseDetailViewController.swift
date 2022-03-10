//
//  ExpenseDetailViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/8/22.
//

import UIKit

class ExpenseDetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var totalExpensesLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var expenses: [Expense]? {
        didSet{
            self.updateViews()
        }
    }
    
    //MARK: - LifyCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewCornersRounded()
    }
    
    //MARK: - Data Source methods
    
    
    //MARK: - Helper Methods
    private func viewCornersRounded() {
        tableView.layer.cornerRadius = 16
    }
    

    
    func updateViews() {
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toAddExpenseVC",
//           let indexPath = tableView.indexPathForRow,
//           let destination = segue.destination as? AddExpenseViewController {
//            let expenses = ExpenseDetailViewController.shared.fetchExpenses(completion: <#T##(Bool) -> Void#>)
//        }
//    }
    
} //End of class

