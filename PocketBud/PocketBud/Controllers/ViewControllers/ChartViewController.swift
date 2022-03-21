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
    
    //MARK: - Properties
    
    var budgetDate = Date()
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
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        pieChartDataSet.form = .circle
       
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        let format = NumberFormatter()
        format.numberStyle = .currency
        
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        currentMonthPieChart.drawEntryLabelsEnabled = false
        currentMonthPieChart.data = pieChartData
    }

    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
      var colors: [UIColor] = []
      for _ in 0..<numbersOfColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        colors.append(color)
      }
      return colors
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
} //End of class
