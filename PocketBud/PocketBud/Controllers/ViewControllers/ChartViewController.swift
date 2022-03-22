//
//  ChartViewController.swift
//  PocketBud
//
//  Created by Jonmichael Cheung on 3/18/22.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    //MARK: -
    
    @IBOutlet weak var currentMonthPieChart: PieChartView!
    @IBOutlet weak var monthLabel: UILabel!
    
    
    //MARK: - Properties
    var budgetDate = Date()
    var chartColors: [UIColor] = [#colorLiteral(red: 1, green: 0.1491002738, blue: 0, alpha: 1), #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 1, green: 0.173960674, blue: 0.587517369, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.8587893091, green: 0.6070529848, blue: 0.2928512582, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)]
    var categories: [String] = {
        var placeHolder: [String] = []
        CategoryTotalController.shared.categoryTotals.forEach({ placeHolder.append($0.categoryName) })
        return placeHolder
    }()
    
    var totals: [Double] = {
        var placeHolder: [Double] = []
        CategoryTotalController.shared.categoryTotals.forEach({ placeHolder.append($0.total) })
        return placeHolder
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizedChart(dataPoints: categories, values: totals)
        
    }
    
    func customizedChart(dataPoints: [String], values:[Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        
        pieChartDataSet.colors = chartColors
        pieChartDataSet.form = .circle
        pieChartDataSet.valueFont = UIFont(name: "Noteworthy", size: 15)!
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        let format = NumberFormatter()
        format.numberStyle = .currency
        
        format.usesGroupingSeparator = true
        
        let myFormatter = MyValueFormatter()
        pieChartData.setValueFormatter(myFormatter)
        
        currentMonthPieChart.legend.font = UIFont(name: "Baskerville", size: 19)!
        currentMonthPieChart.drawEntryLabelsEnabled = false
        currentMonthPieChart.data = pieChartData
        
        monthLabel.text = budgetDate.dateAsMonth()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
} //End of class

class MyValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
//        return ConvertToDollar.shared.toDollar(value: value)
        return "$\(value)"
    }
} //End of class
