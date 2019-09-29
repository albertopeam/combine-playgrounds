import Combine

var subscriptions = Set<AnyCancellable>()

func run() {
    let contacts = [
      "603-555-1234": "Florent",
      "408-555-4321": "Marin",
      "217-555-1212": "Scott",
      "212-555-3434": "Shai"
    ]

    func convert(phoneNumber: String) -> Int? {
      if let number = Int(phoneNumber),
        number < 10 {
        return number
      }

      let keyMap: [String: Int] = [
        "abc": 2, "def": 3, "ghi": 4,
        "jkl": 5, "mno": 6, "pqrs": 7,
        "tuv": 8, "wxyz": 9
      ]
        
      let character = Character(phoneNumber.lowercased())
      let converted = keyMap
        .filter { $0.key.contains(character) }
        .map { $0.value }
        .first

      return converted
    }

    func format(digits: [Int]) -> String {
      var phone = digits.map(String.init)
                        .joined()

      phone.insert("-", at: phone.index(
        phone.startIndex,
        offsetBy: 3)
      )

      phone.insert("-", at: phone.index(
        phone.startIndex,
        offsetBy: 7)
      )

      return phone
    }

    func dial(phoneNumber: String) -> String {
      guard let contact = contacts[phoneNumber] else {
        return "Contact not found for \(phoneNumber)"
      }

      return "Dialing \(contact) (\(phoneNumber))..."
    }

    let input = PassthroughSubject<String, Never>()

    input.map({ convert(phoneNumber: $0) })
        .replaceNil(with: 0)
        .collect(10)
        .map({ format(digits: $0) })
        .map(dial(phoneNumber:))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    "0!1234567".forEach {
      input.send(String($0))
    }

    "4085554321".forEach {
      input.send(String($0))
    }

    "A1BJKLDGEH".forEach {
      input.send("\($0)")
    }
}

run()
