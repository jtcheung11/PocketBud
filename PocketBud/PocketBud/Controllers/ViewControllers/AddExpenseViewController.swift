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

   
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let businessName = businessNameTextField.text, !businessName.isEmpty,
              //How do I make amountTextfield a Double
              let amount = amountTextField.text, !amount.isEmpty,
              let category = categoryTextField.text, !category.isEmpty
        else { return }
        
        if let amt = Double(amountTextField.text!) {
            print("User input was a double")
            print("Bussiness:\(businessName), Amount:\(amt), Category:\(category)")
        } else{
            print("user input was NOT a number")
        }
        ExpenseDetailTableViewCell.createExpenseDetail(<#ExpenseDetailTableViewCell#>)
        self.dismiss(animated: true, completion: nil)
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
    
    
}
