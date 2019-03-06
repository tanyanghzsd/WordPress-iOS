
import Foundation

import Charts

// MARK: - DaysWeeksMonthsYearsDatum

struct DaysWeeksMonthsYearsDatum: Decodable {
    let date: Date
    let viewCount: Int
    let visitorCount: Int
    let likeCount: Int
    let commentCount: Int
}

// MARK: - DaysWeeksMonthsYearsDataStub

/// Values approximate what's depicted in Zeplin
///
class DaysWeeksMonthsYearsDataStub {

    private(set) var data: [DaysWeeksMonthsYearsDatum]

    init() {
        let fileName = "dwmy_data"
        let bundle = Bundle(for: type(of: self))

        let decoder = StubDataJSONDecoder()
        guard let jsonData = bundle.jsonData(from: fileName),
            let decoded = try? decoder.decode([DaysWeeksMonthsYearsDatum].self, from: jsonData) else {

            fatalError("Failed to decode data from \(fileName).json")
        }

        self.data = decoded
    }
}

// MARK: - BarChartDataConvertible

extension DaysWeeksMonthsYearsDataStub: BarChartDataConvertible {
    var barChartData: BarChartData {

        // Our stub data is ordered
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
