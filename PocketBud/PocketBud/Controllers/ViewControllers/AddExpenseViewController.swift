//
//  AddExpenseViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/7/22.
//

import UIKit

class AddExpenseViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    //MARK: - Properties
    var expense: Expense?
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerViewInput()
        
    }
    
    func pickerViewInput() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextField.inputView = pickerView
        categoryTextField.textAlignment = .center
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let businessName = businessNameTextField.text, !businessName.isEmpty,
              let amount = amountTextField.text, !amount.isEmpty,
              let category = categoryTextField.text, !category.isEmpty,
              let amountAsDouble = Double(amount)
        else { return }
        
        if let expense = expense {
            ExpenseController.shared.updateExpense(expense, category: category, amount: amountAsDouble, business: businessName) { success in
                if success {
                    DispatchQueue.main.async {
                        print("Expense Updated")
                        self.dismiss(animated: true)
                    }
                }
            }
        } else {
            ExpenseController.shared.addExpense(business: businessName, category: category, amount: amountAsDouble) { success in
                if success {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func updateView() {
        guard let expense = expense else { return }
        businessNameTextField.text = expense.business
        categoryTextField.text = expense.category
        amountTextField.text = String(expense.amount)
    }
    
    
    
} //End of class

extension AddExpenseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.allCases[row].rawValue
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = Category.allCases[row].rawValue
        categoryTextField.resignFirstResponder()
    }
    
    
} // End of extension
