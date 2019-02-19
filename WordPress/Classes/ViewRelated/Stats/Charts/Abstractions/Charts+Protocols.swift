
import Charts

// MARK: - BarChartConfiguration

/// Describes the visual appearance of a BarChartView. Implementation TBD.
///
protocol BarChartConfiguration {

    var xAxisValueFormatter: IAxisValueFormatter { get }

    var yAxisValueFormatter: IAxisValueFormatter { get }
}

// MARK: - BarChartDataConvertible

/// Transforms a given data set for consumption by BarChartView in the Charts framework.
///
protocol BarChartDataConvertible {
    var barChartData: BarChartData { get }
}
