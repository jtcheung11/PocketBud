//
//  ExpenseDetailViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/8/22.
//

import UIKit

class ExpenseDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    //MARK: - Outlets
    @IBOutlet weak var totalExpensesLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
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
        updateViews()
    }
    
    //MARK: - Data Source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ExpenseController.shared.expense.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as? ExpenseDetailTableViewCell else { return UITableViewCell()}
        
        let expense = ExpenseController.shared.expense[indexPath.row]
        cell.businessNameLabel.text = String(expense.amount)
        cell.amountLabel.text = String(expense.amount)
//        How do I get the date in here from when the expense was created?
        return cell
    }
    
    //MARK: - Helper Methods
    private func viewCornersRounded() {
        tableView.layer.cornerRadius = 24
        tableView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
    
    
    
    func updateViews() {

//        totalExpensesLabel.text = String(expensesSummed())
    }
    
    func expensesSummed() {
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddExpenseVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? AddExpenseViewController else { return }
            let expense = ExpenseController.shared.expense[indexPath.row]
            destination.expense = expense
        }
    }
} //End of class

