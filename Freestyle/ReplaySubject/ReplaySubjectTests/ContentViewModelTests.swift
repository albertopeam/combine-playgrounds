//
//  ReplaySubjectTests.swift
//  ReplaySubjectTests
//
//  Created by Alberto Penas Amor on 10/03/2020.
//  Copyright © 2020 com.github.albertopeam. All rights reserved.
//

import XCTest
@testable import ReplaySubject

class ContentViewModelTests: XCTestCase {

    func testGivenInitWhenSubscribeToSubjectThenMatchReceiveNotEmpty() {
        let sut: ContentViewModel = .init()

        var result: [ContentViewModel.Model]?
        _ = sut.subject.sink(receiveValue: { result = $0 })

        XCTAssertGreaterThan(try XCTUnwrap(result).count, 0)
    }

}
