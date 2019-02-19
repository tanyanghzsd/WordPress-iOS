
import UIKit

import Charts

// MARK: - StatsBarChartView

class StatsBarChartView: BarChartView {

    // MARK: Properties

    let dataSet: BarChartDataConvertible

    private let barChartConfiguration: BarChartConfiguration

    /// A collection of parameters uses for view layout
    private struct Metrics {
        static let intrinsicHeight = CGFloat(170)   // NB: height via Zeplin
    }

    // From Zeplin, to be extracted
    private let chartColor = UIColor(red: 135/255.0, green: 166/255.0, blue: 188/255.0, alpha: 255.0/255.0)

    // MARK: BarChartView

    init(data: BarChartDataConvertible, configuration: BarChartConfiguration) {
        self.dataSet = data
        self.barChartConfiguration = configuration

        super.init(frame: .zero)

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Metrics.intrinsicHeight)
    }

    // MARK: Private behavior

    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false

        configureAppearance()
        populateData()
    }

    private func configureAppearance() {
        configureBarChartViewProperties()
        configureBarLineChartViewBaseProperties()
        configureChartViewBaseProperties()

        configureXAxis()
        configureYAxis()
    }

    private func configureBarChartViewProperties() {
        drawBarShadowEnabled = false
        drawValueAboveBarEnabled = false
        fitBars = true
    }

    private func configureBarLineChartViewBaseProperties() {
        //autoScaleMinMaxEnabled = true

        doubleTapToZoomEnabled = false
        dragXEnabled = false
        dragYEnabled = false
        pinchZoomEnabled = false

        legend.enabled = false
        rightAxis.enabled = false

        drawBordersEnabled = false
        drawGridBackgroundEnabled = false

        minOffset = CGFloat(0)

        scaleXEnabled = false
        scaleYEnabled = false
    }

    private func configureChartViewBaseProperties() {
        dragDecelerationEnabled = false
        drawMarkers = false
        highlightPerTapEnabled = false

        extraRightOffset = CGFloat(20)

        let animationDuration = TimeInterval(1)
        animate(yAxisDuration: animationDuration)
    }

    private func configureXAxis() {
        xAxis.axisLineColor = chartColor
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLabelsEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = chartColor
        xAxis.setLabelCount(2, force: true)
        xAxis.valueFormatter = barChartConfiguration.xAxisValueFormatter
    }

    private func configureYAxis() {
        let yAxis = leftAxis

        yAxis.gridColor = chartColor
        yAxis.drawAxisLineEnabled = false
        yAxis.drawLabelsEnabled = true
        yAxis.drawZeroLineEnabled = true
        yAxis.labelTextColor = chartColor
        yAxis.valueFormatter = barChartConfiguration.yAxisValueFormatter
    }

    private func populateData() {
        data = dataSet.barChartData
    }
}
