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
    
    var currentDate = Date()
    
    //MARK: - LifyCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        cell.businessNameLabel.text = String(expense.business)
        cell.amountLabel.text = String(expense.amount)
        cell.dateLabel.text = currentDate.stringValue()
//        How do I get the date in here from when the expense was created?
        return cell
    }
    
    //Editing Style to delete
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
    
    //MARK: - Helper Methods
    private func viewCornersRounded() {
        tableView.layer.cornerRadius = 24
        tableView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
    
    
    
    func updateViews() {
//        expensesSummed()
    }
    
    func expensesSummed() {
        tableView.reloadData()
        currentDateLabel.text = currentDate.stringValue()
            let total = ExpenseController.shared.expense.reduce(into: 0.0) { partialResult, expensesTotal in
                partialResult += expensesTotal.amount
            }
        totalExpensesLabel.text = "$" + String(format: "%.2f", total)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddExpenseVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? AddExpenseViewController else { return }
            let expense = ExpenseController.shared.expense[indexPath.row]
//            destination.expense =
        }
    }
} //End of class

