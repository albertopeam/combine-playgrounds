import Combine
import Foundation

Just<String>("Filename")
    .print()
    .tryMap({ try FileManager.default.contentsOfDirectory(atPath: $0) })
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
