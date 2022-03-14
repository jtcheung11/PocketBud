//
//  BudgetViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/9/22.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    //MARK: - Outlets
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var incomeAndCateogryTotalsView: UIView!
    @IBOutlet weak var categoryTotalsTableView: UITableView!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var currentTotalSpentLabel: UILabel!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressBarBar: UIView!
    
    //MARK: - Properties
    
    var expensesFromCloudKit = [Expense]()
    
//    var categoryTotal = CategoryTotal
      var budgetDate = Date()
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTextField.delegate = self
        categoryTotalsTableView.delegate = self
        categoryTotalsTableView.dataSource = self
        fetchCategoryTotals()
        viewCornersRounded()
        fetchExpensesAndAssignToEmptyArray()
        updateViews()
        
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.refreshData(notification:)), name:
            Notification.Name("RefreshNotificationIdentifier"), object: nil)
    }
    
    func fetchExpensesAndAssignToEmptyArray() {
        ExpenseController.shared.fetchExpenses { success in
            if success {
                print(ExpenseController.shared.expense)
            }
        }
    }
    
    @objc func refreshData(notification: Notification) {
        //TODO: - Account for delay in saving/fetching data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.updateViews()
        }
    }
    
    //MARK: - DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryTotalController.shared.categoryTotals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let categoryTotal = CategoryTotalController.shared.categoryTotals[indexPath.row]
        
        var config = cell.defaultContentConfiguration()

        config.text = categoryTotal.categoryName
        config.secondaryText = String(categoryTotal.total)

        cell.contentConfiguration = config

        return cell
    }
    
    //MARK: - Helper Methods
    
    private func viewCornersRounded() {
        progressBarView.layer.cornerRadius = 24
        progressBarView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        incomeAndCateogryTotalsView.layer.cornerRadius = 24
        incomeAndCateogryTotalsView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
    
    @IBAction func leftArrowButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func rightArrowButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func updateIncomeButtonTapped(_ sender: UIButton) {
        guard let incomeString = incomeTextField.text, !incomeString.isEmpty,
              let income = Double(incomeString)
        else { return }
        incomeLabel.text = "$" + String(format: "%.2f", income)
        print(income)
        incomeTextField.text = ""
    }
    
    func fetchCategoryTotals() {
        CategoryTotalController.shared.fetchCategoryTotals(date: Date()) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.updateViews()
                    print("Successful in fetching all categoryTotals")
                } else {
                    print("Failed to fetch all categoryTotals")
                }
            }
        }
    }
    
    func updateViews(){
        categoryTotalsTableView.reloadData()
        monthLabel.text = budgetDate.dateAsMonth()
        let total = CategoryTotalController.shared.categoryTotals.reduce(into: 0.0) { partialResult, categoryTotal in
            partialResult += categoryTotal.total
        }
        currentTotalSpentLabel.text = "$" + String(format: "%.2f", total)
        
    }
    
    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExpenseDetailDV" {
            guard let destinationVC = segue.destination as? ExpenseDetailViewController else { return }
            //TODO: - Custom fetch call
            guard let indexPath = categoryTotalsTableView.indexPathForSelectedRow else { return }
            let categoryThatWasTapped = CategoryTotalController.shared.categoryTotals[indexPath.row]
//            Fetch totalCategories as predicate and filter expenses based on the categoryTapped
            /// destinationVC.expense = Expenses with category specified
            destinationVC.expenses = ExpenseController.shared.expense
            
        }
    }
    

} //End of class


    
