//
//  ChartCell.swift
//  TestNachiOS
//
//  Created by Luis Rodrigo Gonzalez Vazquez on 07/03/22.
//

import UIKit
import Charts
 
public class ChartCell: UITableViewCell {
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var title: UILabel!
    
    
    public func configure(dataPoints: [String], values: [Double], questionTitle: String, colors: [String]) {
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
          let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
          dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
          let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = transformHexColor(with: colors)
        pieChartDataSet.entryLabelFont = UIFont(name: "Verdana", size: 15.0)
        chartView.legend.enabled = true
        chartView.legend.font = UIFont.systemFont(ofSize: 12.0)
        chartView.holeRadiusPercent = 0.4
        chartView.transparentCircleRadiusPercent = 0.0
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 2
            formatter.multiplier = 1.0
            formatter.percentSymbol = "%"
            pieChartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        // 4. Assign it to the chart’s data
        chartView.data = pieChartData
        title.text = questionTitle
  }
    
    private func transformHexColor(with stringColors: [String]) -> [UIColor]{
        var colors: [UIColor] = []
        for hexColor in stringColors{
            let color = hexStringToUIColor(hex: hexColor)
                colors.append(color)
        }
        return colors
    }
}

public func hexStringToUIColor (hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
