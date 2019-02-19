
import Foundation

import Charts

// MARK: - LatestPostSummaryDatum

struct LatestPostSummaryDatum: Decodable {
    let date: Date
    let viewCount: Int

    private enum CodingKeys: String, CodingKey {
        case date       = "day"
        case viewCount  = "count"
    }
}

// MARK: - LatestPostSummaryDateFormatter

private class LatestPostSummaryDateFormatter: DateFormatter {
    override init() {
        super.init()

        self.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormat = "yyyy-MM-dd"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LatestPostSummaryDataStub

/// Stub structure informed by https://developer.wordpress.com/docs/api/1.1/get/sites/%24site/stats/post/%24post_id/
/// Values approximate what's depicted in Zeplin
///
class LatestPostSummaryDataStub {

    private static let jsonFileName        = "lps_withData"
    private static let jsonFileExtension   = "json"

    private(set) var data: [LatestPostSummaryDatum]

    init() {
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(
            forResource: LatestPostSummaryDataStub.jsonFileName,
            withExtension: LatestPostSummaryDataStub.jsonFileExtension) else {

            fatalError("Failed to locate \(LatestPostSummaryDataStub.jsonFileName).\(LatestPostSummaryDataStub.jsonFileExtension) in bundle.")
        }

        guard let jsonData = try? Data(contentsOf: url) else {
            fatalError("Failed to parse \(LatestPostSummaryDataStub.jsonFileName).\(LatestPostSummaryDataStub.jsonFileExtension) as Data.")
        }

        let decoder = JSONDecoder()
        let dateFormatter = LatestPostSummaryDateFormatter()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        guard let decoded = try? decoder.decode([LatestPostSummaryDatum].self, from: jsonData) else {
            fatalError("Failed to decode \(LatestPostSummaryDataStub.jsonFileName).\(LatestPostSummaryDataStub.jsonFileExtension) from data")
        }

        self.data = decoded
    }
}

extension LatestPostSummaryDataStub: BarChartDataConvertible {
    var barChartData: BarChartData {

        // For our stub data, our data source is ordered
        let firstDateInterval: TimeInterval
        let lastDateInterval: TimeInterval
        let effectiveWidth: Double

        if data.isEmpty {
            firstDateInterval = 0
            lastDateInterval = 0
            effectiveWidth = 1
        } else {
            firstDateInterval = data.first!.date.timeIntervalSince1970
            lastDateInterval = data.last!.date.timeIntervalSince1970

            let range = lastDateInterval - firstDateInterval

            let effectiveBars = Double(Double(data.count) * 1.2)

            effectiveWidth = range / effectiveBars
        }

        var entries = [BarChartDataEntry]()
        for datum in data {
            let dateInterval = datum.date.timeIntervalSince1970
            let offset = dateInterval - firstDateInterval

            let x = offset
            let y = Double(datum.viewCount)
            let entry = BarChartDataEntry(x: x, y: y)

            entries.append(entry)
        }

        let chartData = BarChartData(entries: entries)
        chartData.barWidth = effectiveWidth

        return chartData
    }
}
