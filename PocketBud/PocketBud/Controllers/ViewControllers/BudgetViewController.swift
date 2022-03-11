//
//  BudgetViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/9/22.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - Outlets
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var incomeAndCateogryTotalsView: UIView!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var currentTotalSpentLabel: UILabel!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressBarBar: UIView!
    
    //MARK: - Properties
//    var categoryTotal = CategoryTotal
      var budgetDate = Date()
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategoryTotals()
        viewCornersRounded()
        updateViews()
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
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let selectedCategoryTotal = CategoryTotalController.shared.categoryTotals[indexPath.row]
    //
    //    }
    
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
        guard let income = incomeTextField.text, !income.isEmpty
        else { return }
        incomeLabel.text = income
        incomeTextField.text = nil
        
        //percent = totalCategory summed / income * 100 (rounded to neared whole Int)
        // percentLabel.text = percent
        
        // currentValueOfProgressBar = Int(percent)
        //progressBarBar= currentValueOfProgressBar
        
        //Bonus: Alert user if they do not input a Double
    }
    
    func fetchCategoryTotals() {
        CategoryTotalController.shared.fetchCategoryTotals(date: Date()) { success in
            if success {
                self.updateViews()
                print("Successful in fetching all categoryTotals")
            } else {
                print("Failed to fetch all categoryTotals")
            }
        }
    }
    
    func updateViews(){
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
            destinationVC.expenses = ExpenseController.shared.expense
        }
    }
    

} //End of class


    
