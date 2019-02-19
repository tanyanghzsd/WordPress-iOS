
import Foundation

import Charts

// MARK: - LatestPostSummaryBarChartConfiguration

class LatestPostSummaryBarChartConfiguration: BarChartConfiguration {

    // MARK: Properties

    private let data: [LatestPostSummaryDatum]

    let xAxisValueFormatter: IAxisValueFormatter

    let yAxisValueFormatter: IAxisValueFormatter

    // MARK: LatestPostSummaryBarChartConfiguration

    init(rawData: [LatestPostSummaryDatum]) {
        self.data = rawData

        let firstDateInterval = rawData.first?.date.timeIntervalSince1970 ?? 0
        self.xAxisValueFormatter = LatestPostSummaryHorizontalAxisFormatter(initialDateInterval: firstDateInterval)

        self.yAxisValueFormatter = LatestPostSummaryVerticalAxisFormatter()
    }
}

// MARK: - LatestPostSummaryHorizontalAxisFormatter

class LatestPostSummaryHorizontalAxisFormatter: IAxisValueFormatter {

    // MARK: Properties

    private let initialDateInterval: TimeInterval

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM dd")

        return formatter
    }()

    // MARK: LatestPostSummaryHorizontalAxisFormatter

    init(initialDateInterval: TimeInterval) {
        self.initialDateInterval = initialDateInterval
    }

    // MARK: IAxisValueFormatter

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let adjustedValue = initialDateInterval + value
        let date = Date(timeIntervalSince1970: adjustedValue)
        let value = formatter.string(from: date)

        return value
    }
}

// MARK: - LatestPostSummaryVerticalAxisFormatter

class LatestPostSummaryVerticalAxisFormatter: IAxisValueFormatter {

    // MARK: Properties
    
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.maximumFractionDigits = 0

        return formatter
    }()

    // MARK: IAxisValueFormatter

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let number = NSNumber(value: value/1000)
        let value = formatter.string(from: number) ?? ""

        // Admittedly not the most locale-sensitive formatting approach, but it is stub data
        let format = NSLocalizedString("%@k", comment: "Abbreviation representing thousands")
        let formattedValue = String(format: format, value)

        return formattedValue
    }
}
