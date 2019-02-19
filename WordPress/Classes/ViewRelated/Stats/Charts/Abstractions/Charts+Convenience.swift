
import Charts

// MARK: - BarChartData

extension BarChartData {
    convenience init(entries: [BarChartDataEntry]) {
        let dataSet = BarChartDataSet(values: entries)
        self.init(dataSets: [dataSet])
    }
}

// MARK: - BarChartDataSet

extension BarChartDataSet {
    convenience init(values: [BarChartDataEntry]) {
        self.init(values: values, label: nil)

        highlightEnabled = false
        drawValuesEnabled = false

        let barColor = WPStyleGuide.wordPressBlue()
        colors = [ barColor ]
    }
}
