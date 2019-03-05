
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

class DaysWeeksMonthsYearsDataStub {}
