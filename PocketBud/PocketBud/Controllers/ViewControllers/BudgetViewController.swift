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
    @IBOutlet weak var percentBarProgressView: UIProgressView!
    
    //MARK: - Properties
    var expensesFromCloudKit = [Expense]()
    var budgetDate = Date()
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchCategoryTotals()
        fetchIncomeVDL()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateViews()
    }
    
    @objc func refreshData(notification: Notification) {
        self.updateViews()
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
        let total = categoryTotal.total
        config.secondaryText = ConvertToDollar.shared.toDollar(value: total)
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    //MARK: - Helper Methods
    private func setUpView() {
        incomeTextField.delegate = self
        categoryTotalsTableView.delegate = self
        categoryTotalsTableView.dataSource = self
        viewCornersRounded()
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(self.refreshData(notification:)), name:
                                                Notification.Name("RefreshNotificationIdentifier"), object: nil)
    }
    
    private func viewCornersRounded() {
        progressBarView.layer.cornerRadius = 24
        progressBarView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        incomeAndCateogryTotalsView.layer.cornerRadius = 24
        incomeAndCateogryTotalsView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
    
    func fetchIncomeVDL() {
        IncomeController.shared.fetchIncome { success in
            if success {
                DispatchQueue.main.async {
                    guard let currentIncome = IncomeController.shared.currentIncome
                    else { return }
                    self.incomeLabel.text = ConvertToDollar.shared.toDollar(value: currentIncome.income)
                    self.percentCalcuated()
                }
            }
        }
    }
    
    func percentCalcuated() {
        
        guard let spent = currentTotalSpentLabel.text, !spent.isEmpty,
              let income = incomeLabel.text, !income.isEmpty
        else { return }

        let currentSpent = Double(spent.dropFirst()) ?? 0
        let currentIncome = Double(income.dropFirst()) ?? 1
    
        let percent = (currentSpent / currentIncome) * 100
        let percentWithSymbol = String(format: "%.1f",percent) + "%"
        percentLabel.text = String(percentWithSymbol)
        percentBarProgressView.progress = Float(currentSpent / currentIncome)
    }
    
    @IBAction func leftArrowButtonTapped(_ sender: Any) {
        budgetDate = Calendar.current.date(byAdding: .month, value: -1, to: budgetDate) ?? Date()
        fetchCategoryTotals()
        ExpenseController.shared.expenses = []
    }
    
    @IBAction func rightArrowButtonTapped(_ sender: Any) {
        budgetDate = Calendar.current.date(byAdding: .month, value: 1, to: budgetDate) ?? Date()
        fetchCategoryTotals()
        ExpenseController.shared.expenses = []
    }
    
    @IBAction func updateIncomeButtonTapped(_ sender: UIButton) {
        guard let incomeString = incomeTextField.text, !incomeString.isEmpty,
              let income = Double(incomeString)
        else { return }
        if let currentIncome = IncomeController.shared.currentIncome{
            let incomeComponents = Calendar.current.dateComponents([.month , .year], from: currentIncome.date)
            let currentComponents = Calendar.current.dateComponents([.month , .year], from: Date())
            guard let incomeMonth = incomeComponents.month,
                  let incomeYear = incomeComponents.year,
                  let currentMonth = currentComponents.month,
                  let currentYear = currentComponents.year else { return }
            
            if incomeMonth == currentMonth && incomeYear == currentYear {
                IncomeController.shared.updateIncome(currentIncome, newIncome: income) { success in
                    if success {
                        print("Successfully updated current Income to \(income)")
                    }
                }
            } else {
                IncomeController.shared.createIncome(income: income) { success in
                    if success {
                        print("Successfully created a new Income: \(income)")
                    }
                }
            }
        } else {
            IncomeController.shared.createIncome(income: income) { success in
                if success {
                    print("Successfully created a new Income as \(income)")
                }
            }
        }
        
        incomeLabel.text = ConvertToDollar.shared.toDollar(value: income)
        print(income)
        incomeTextField.text = ""
        percentCalcuated()
    }

    @IBAction func toCurrentMonthButtonTapped(_ sender: UIButton) {
        if budgetDate != Date() {
            budgetDate = Date()
            fetchCategoryTotals()
            ExpenseController.shared.expenses = []
            updateViews()
        }
    }
    
    func fetchCategoryTotals() {
        CategoryTotalController.shared.fetchCategoryTotals(date: budgetDate) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.updateViews()
                    self?.percentCalcuated()
                    print("Successful in fetching all categoryTotals")
                } else {
                    print("Failed to fetch all categoryTotals")
                }
            }
        }
    }
    
    
    func updateViews() {
        categoryTotalsTableView.reloadData()
        monthLabel.text = budgetDate.dateAsMonth()
        let total = CategoryTotalController.shared.categoryTotals.reduce(into: 0.0) { partialResult, categoryTotal in
            partialResult += categoryTotal.total
        }
        currentTotalSpentLabel.text = ConvertToDollar.shared.toDollar(value: total)
        percentCalcuated()
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ExpenseDetailViewController else { return }
        if segue.identifier == "toExpenseDetailDV" {
            guard let indexPath = categoryTotalsTableView.indexPathForSelectedRow else { return }
            let categoryThatWasTapped = CategoryTotalController.shared.categoryTotals[indexPath.row]
            destinationVC.categoryTotal = categoryThatWasTapped
        }
        destinationVC.currentDate = budgetDate
    }
} //End of class
