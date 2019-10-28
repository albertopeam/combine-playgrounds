import Combine
import Foundation

struct TimeLogger: TextOutputStream {
    private var previous = Date()
    private var formatter = NumberFormatter()
    
    init() {
        formatter.minimumFractionDigits = 5
        formatter.maximumFractionDigits = 5
    }
    
    mutating func write(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
        previous = now
    }
}

var subscriptions = Set<AnyCancellable>()
(1...10).publisher
    .print("publisher", to: TimeLogger())
    .sink(receiveValue: { _ in})
    .store(in: &subscriptions)


