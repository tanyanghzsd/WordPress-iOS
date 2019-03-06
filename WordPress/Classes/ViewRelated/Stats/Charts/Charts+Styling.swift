
import Foundation

import Charts

// MARK: - PeriodPerformanceStyling

class PeriodPerformanceStyling: BarChartStyling {

    let primaryBarColor: UIColor
    let secondaryBarColor: UIColor?
    let highlightColor: UIColor?
    let labelColor: UIColor
    let legendEnabled: Bool
    let lineColor: UIColor
    let xAxisValueFormatter: IAxisValueFormatter
    let yAxisValueFormatter: IAxisValueFormatter

    init(initialDateInterval: TimeInterval, highlightColor: UIColor? = nil) {
        let xAxisFormatter = HorizontalAxisFormatter(initialDateInterval: initialDateInterval)

        self.primaryBarColor        = WPStyleGuide.wordPressBlue()
        self.secondaryBarColor      = WPStyleGuide.darkBlue()
        self.highlightColor         = WPStyleGuide.jazzyOrange()
        self.labelColor             = WPStyleGuide.grey()
        self.legendEnabled          = true
        self.lineColor              = WPStyleGuide.greyLighten30()
        self.xAxisValueFormatter    = xAxisFormatter
        self.yAxisValueFormatter    = VerticalAxisFormatter()
    }
}

// MARK: - PostSummaryStyling

class PostSummaryStyling: BarChartStyling {

    let primaryBarColor: UIColor
    let secondaryBarColor: UIColor?
    let highlightColor: UIColor?
    let labelColor: UIColor
    let legendEnabled: Bool
    let lineColor: UIColor
    let xAxisValueFormatter: IAxisValueFormatter
    let yAxisValueFormatter: IAxisValueFormatter

    init(barColor: UIColor, highlightColor: UIColor?, labelColor: UIColor, lineColor: UIColor, xAxisValueFormatter: IAxisValueFormatter, yAxisValueFormatter: IAxisValueFormatter) {
        self.primaryBarColor        = barColor
        self.secondaryBarColor      = nil
        self.highlightColor         = highlightColor
        self.labelColor             = labelColor
        self.legendEnabled          = false
        self.lineColor              = lineColor
        self.xAxisValueFormatter    = xAxisValueFormatter
        self.yAxisValueFormatter    = yAxisValueFormatter
    }
}
