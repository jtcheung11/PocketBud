//
//  AlertExtension.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/23/22.
//

import UIKit

extension UIViewController {
    
    func errorFetchingCT() {
        let alertController = UIAlertController(title: "Error", message: "Unable fetch your Category Totals from the iCloud, Please make sure you are logged into your Apple account.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Close", style: .cancel)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    func errorFetchingExenses() {
        let alertController = UIAlertController(title: "Error", message: "Unable to fetch your Expenses from iCloud, Please make sure you are logged into your Apple account.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Close", style: .cancel)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
}
