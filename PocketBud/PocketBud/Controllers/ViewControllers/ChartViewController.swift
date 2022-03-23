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
    var chartColors: [UIColor] = [#colorLiteral(red: 0.4392156863, green: 0.5529411765, blue: 0.5058823529, alpha: 1), #colorLiteral(red: 0.3450980392, green: 0.6431372549, blue: 0.6901960784, alpha: 1), #colorLiteral(red: 0.2588235294, green: 0.5058823529, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.3333333333, green: 0.5098039216, blue: 0.5450980392, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.1333333333, green: 0.2, blue: 0.231372549, alpha: 1), #colorLiteral(red: 0.2117647059, green: 0.2862745098, blue: 0.3450980392, alpha: 1), #colorLiteral(red: 0.4969162549, green: 0.7700697986, blue: 0.8522654515, alpha: 1), #colorLiteral(red: 0.0862745098, green: 0.4117647059, blue: 0.4784313725, alpha: 1), #colorLiteral(red: 0, green: 0.1058823529, blue: 0.1803921569, alpha: 1)]
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
        currentMonthPieChart.delegate = self
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
        pieChartDataSet.valueFont = UIFont(name: "Baskerville", size: 15)!
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        let format = NumberFormatter()
        format.numberStyle = .currency
        
        format.usesGroupingSeparator = true
        
        let myFormatter = MyValueFormatter()
        pieChartData.setValueFormatter(myFormatter)
        
        currentMonthPieChart.legend.font = UIFont(name: "Baskerville", size: 19)!
        currentMonthPieChart.drawEntryLabelsEnabled = false
        currentMonthPieChart.data = pieChartData
        currentMonthPieChart.rotationEnabled = false
        currentMonthPieChart.drawHoleEnabled = false
        currentMonthPieChart.noDataFont = UIFont(name: "Baskerville", size: 25)!
        
        monthLabel.text = budgetDate.dateAsMonth()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
} //End of class

class MyValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return ConvertToDollar.shared.toDollar(value: value)
    }
} //End of class

extension ChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    }
}
