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
    var expenses: [Expense] = []
    var categoryTotal: CategoryTotal?
    
    var currentDate = Date()
    
    //MARK: - LifyCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchExpensesVDL()
        tableView.delegate = self
        tableView.dataSource = self
        viewCornersRounded()
        updateViews()
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.refreshData(notification:)), name:
                                                Notification.Name("RefreshNotificationIdentifier"), object: nil)
    }
    
    @objc func refreshData(notification: Notification) {
        self.updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViews()
    }
    
    //MARK: - Data Source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as? ExpenseDetailTableViewCell else { return UITableViewCell()}
        
        let expense = expenses[indexPath.row]
        cell.expense = expense
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expenseToDelete = expenses[indexPath.row]
            guard let index = expenses.firstIndex(of: expenseToDelete)
            else { return }
            
            ExpenseController.shared.deleteExpense(expenseToDelete) { [weak self] (success) in
                if success {
                    self?.expenses.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        if self?.expenses.count == 0 {
                            self?.navigationController?.popViewController(animated: true)
                        } else {
                            self?.updateViews()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //MARK: - Helper Methods
    private func viewCornersRounded() {
        tableView.layer.cornerRadius = 24
        tableView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
    
    
    func updateViews() {
        
        currentDateLabel.text = currentDate.monthDayYear()
        
        
        if let categoryTotal = categoryTotal {
            let total = categoryTotal.total
            totalExpensesLabel.text = ConvertToDollar.shared.toDollar(value: total)
            
            expenses = ExpenseController.shared.expenses.filter({ $0.category == categoryTotal.categoryName })
            tableView.reloadData()
        } else {
            let total = CategoryTotalController.shared.categoryTotals.reduce(into: 0.0) { partialResult, categoryTotal in
                partialResult += categoryTotal.total
            }
            totalExpensesLabel.text = ConvertToDollar.shared.toDollar(value: total)
            expenses = ExpenseController.shared.expenses
            tableView.reloadData()
        }
    }
    
    func expensesSummed() {
        self.updateViews()
        currentDateLabel.text = currentDate.stringValue()
        let total = ExpenseController.shared.expenses.reduce(into: 0.0) { partialResult, expensesTotal in
            partialResult += expensesTotal.amount
        }
        totalExpensesLabel.text = ConvertToDollar.shared.toDollar(value: total)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddExpenseVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? AddExpenseViewController else { return }
            let expenseThatWasTapped = expenses[indexPath.row]
            destination.expense = expenseThatWasTapped
        }
    }
    
    func fetchExpensesVDL() {
        if ExpenseController.shared.expenses.isEmpty{
            ExpenseController.shared.fetchExpenses { success in
                if success {
                    DispatchQueue.main.async {
                        self.updateViews()
                        print(ExpenseController.shared.expenses)
                    }
                }
            }
        }
    }
} //End of class

