
import Foundation

import Charts

// MARK: - PeriodPerformanceStyling

//class PeriodPerformanceStyling: BarChartStyling {}

// MARK: - PostSummaryStyling

class PostSummaryStyling: BarChartStyling {
    let primaryBarColor: UIColor
    let secondaryBarColor: UIColor?
    let highlightColor: UIColor?
    let labelColor: UIColor
    let legendTitle: String?
    let lineColor: UIColor
    let xAxisValueFormatter: IAxisValueFormatter
    let yAxisValueFormatter: IAxisValueFormatter

    init(barColor: UIColor, highlightColor: UIColor?, labelColor: UIColor, lineColor: UIColor, xAxisValueFormatter: IAxisValueFormatter, yAxisValueFormatter: IAxisValueFormatter) {
        self.primaryBarColor        = barColor
        self.secondaryBarColor      = nil
        self.highlightColor         = highlightColor
        self.labelColor             = labelColor
        self.legendTitle            = nil
        self.lineColor              = lineColor
        self.xAxisValueFormatter    = xAxisValueFormatter
        self.yAxisValueFormatter    = yAxisValueFormatter
    }
}
