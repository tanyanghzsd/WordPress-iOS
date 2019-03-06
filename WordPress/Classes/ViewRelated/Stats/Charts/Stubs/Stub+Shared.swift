
import Foundation

import Charts

// MARK: - Bundle support

extension Bundle {
    func jsonData(from fileName: String) -> Data? {
        guard let url = url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName).json in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to parse \(fileName).json as Data.")
        }

        return data
    }
}

// MARK: - StubData



// MARK: - StubDataDateFormatter

class StubDataDateFormatter: DateFormatter {
    override init() {
        super.init()

        self.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormat = "yyyy-MM-dd"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - StubDataJSONDecoder

class StubDataJSONDecoder: JSONDecoder {
    override init() {
        super.init()

        let dateFormatter = StubDataDateFormatter()
        dateDecodingStrategy = .formatted(dateFormatter)
    }
}
