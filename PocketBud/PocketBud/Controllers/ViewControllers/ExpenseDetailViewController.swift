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
    
    //MARK: - Properties
    var expense: Expense? {
        didSet{
            self.updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateView() {
//        totalExpensesLabel.text = 
    }
    

}
