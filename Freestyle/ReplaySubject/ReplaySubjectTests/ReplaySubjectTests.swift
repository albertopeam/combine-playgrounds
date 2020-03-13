//
//  ReplaySubjectTests.swift
//  ReplaySubjectTests
//
//  Created by Alberto Penas Amor on 11/03/2020.
//  Copyright © 2020 com.github.albertopeam. All rights reserved.
//

import XCTest
import Combine
@testable import ReplaySubject

class ReplaySubjectTests: XCTestCase {

    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        subscriptions = .init()
    }

    override func tearDown() {
        subscriptions = nil
        super.tearDown()
    }

    // MARK: - sending

    func testGivenNotBufferingWhenSendAfterSubscribeThenMatchAsReceived() {
        let sut = ReplaySubject<Int, Never>(1)

        var result: Int?
        sut.sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)
        sut.send(0)

        XCTAssertEqual(result, 0)
    }

    func testGivenNotBufferingWhenSendAndCompleteAfterSubscribeThenMatchAsReceived() {
        let sut = ReplaySubject<Int, Never>(0)

        var result: Int?
        var completion: Subscribers.Completion<Never>?
        sut.sink(receiveCompletion: { completion = $0 }, receiveValue: { result = $0 })
            .store(in: &subscriptions)
        sut.send(1)
        sut.send(completion: .finished)

        XCTAssertEqual(result, 1)
        XCTAssertEqual(completion, Subscribers.Completion.finished)
    }

    // MARK: error

    func testWhenSendValueAndErrorThenMatchBothAsReceived() {
        enum Error: Swift.Error { case some }
        let sut = ReplaySubject<Int, Error>(1)
        sut.send(1)
        sut.send(completion: .failure(.some))

        var result: Int?
        var completion: Subscribers.Completion<Error>?
        sut.sink(receiveCompletion: { completion = $0 }, receiveValue: { result = $0 })
            .store(in: &subscriptions)

        XCTAssertEqual(result, 1)
        XCTAssertEqual(completion, Subscribers.Completion.failure(.some))
    }

    // MARK: - canceling

    func testGivenCanceledWhenSendAndCompleteThenDontReceive() {
        let sut = ReplaySubject<Int, Never>(1)

        var result: Int?
        var completion: Subscribers.Completion<Never>?
        sut.sink(receiveCompletion: { completion = $0 }, receiveValue: { result = $0 })
            .store(in: &subscriptions)
        subscriptions.forEach({ $0.cancel() })
        sut.send(1)
        sut.send(completion: .finished)

        XCTAssertNil(result)
        XCTAssertNil(completion)
    }

    // MARK: - buffering

    func testGivenNoBufferingWhenSubscribeAfterSentDataThenMatchNotReceiveNothing() {
        let sut = ReplaySubject<Int, Never>(0)
        sut.send(0)

        var result: Int?
        sut.sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        XCTAssertNil(result)
    }

    func testGivenBuffersOneWhenSubscribeAfterSentOneItemThenMatchAsReceived() {
        let sut = ReplaySubject<Int, Never>(1)
        sut.send(0)

        var result: Int?
        sut.sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        XCTAssertNotNil(result)
    }

    func testGivenBuffersTwoWhenSubscribeAfterSentOneItemThenMatchAsReceivedLast() {
        let sut = ReplaySubject<Int, Never>(1)
        sut.send(0)
        sut.send(1)

        var result: Int?
        sut.sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        XCTAssertEqual(result, 1)
    }

    func testGivenTwoElementsSentWhenSubscribeThenReceiveBoth() {
        let sut = ReplaySubject<Int, Never>(2)
        sut.send(0)
        sut.send(1)

        var results: [Int] = .init()
        sut.sink(receiveValue: { results.append($0) })
            .store(in: &subscriptions)

        XCTAssertEqual(results, [0, 1])
    }

    // MARK: - completion

    func testGivenFinishedWhenSubscribeThenMatchCompleted() {
        let sut = ReplaySubject<Int, Never>(0)
        sut.send(completion: .finished)

        var completion: Subscribers.Completion<Never>?
        sut.sink(receiveCompletion: { completion = $0 }, receiveValue: { _ in })
            .store(in: &subscriptions)

        XCTAssertNotNil(completion)
    }

    func testGivenSentAndFinishedWhenSubscribeThenMatchReceiveAndComplete() {
        let sut = ReplaySubject<Int, Never>(1)
        sut.send(0)
        sut.send(completion: .finished)

        var result: Int?
        var completion: Subscribers.Completion<Never>?
        sut.sink(receiveCompletion: { completion = $0 }, receiveValue: { result = $0 })
            .store(in: &subscriptions)

        XCTAssertNotNil(result)
        XCTAssertNotNil(completion)
    }

    func testWhenFinishedThenMatchCompleteOnce() {
        let sut = ReplaySubject<Int, Never>(1)
        sut.send(completion: .finished)
        sut.send(completion: .finished)

        var times: Int = 0
        sut.sink(receiveCompletion: { _ in times += 1 }, receiveValue: { _ in })
            .store(in: &subscriptions)

        XCTAssertEqual(times, 1)
    }

    // MARK: - subscriber

    func testGivenNotBufferingWhenSubscribeAfterSendEventsThenMatchAsNotReceived() {
        let sut = ReplaySubject<Int, Never>(0)
        sut.send(0)
        sut.send(completion: .finished)

        let subscriber = IntSubscriber()
        sut.receive(subscriber: subscriber)

        XCTAssertNotNil(subscriber.subscription)
        XCTAssertEqual(subscriber.received.count, 0)
        XCTAssertEqual(subscriber.completion, Subscribers.Completion.finished)
    }

    func testGivenSentEventAndFinishWhenSubscribeThenMatchAsReceived() {
        let sut = ReplaySubject<Int, Never>(1)
        sut.send(0)
        sut.send(completion: .finished)

        let subscriber = IntSubscriber()
        sut.receive(subscriber: subscriber)

        XCTAssertNotNil(subscriber.subscription)
        XCTAssertEqual(subscriber.received, [0])
        XCTAssertEqual(subscriber.completion, Subscribers.Completion.finished)
    }

    func testGivenSubscribeWhenSentEventAndFinishThenMatchAsReceived() {
        let sut = ReplaySubject<Int, Never>(1)

        let subscriber = IntSubscriber()
        sut.receive(subscriber: subscriber)
        sut.send(0)
        sut.send(completion: .finished)

        XCTAssertNotNil(subscriber.subscription)
        XCTAssertEqual(subscriber.received, [0])
        XCTAssertEqual(subscriber.completion, Subscribers.Completion.finished)
    }

    // MARK: - locking + threading

    func testGivenTwoThreadsWhenSendValuesAndFinishThenMatchAsReceived() {
        let sut = ReplaySubject<Int, Never>(3)
        Thread(block: { sut.send(1) }).start()
        Thread(block: { sut.send(0) }).start()
        Thread(block: { sut.send(4) }).start()
        Thread(block: { Thread.sleep(forTimeInterval: 0.75); sut.send(completion: .finished) }).start()

        var result: [Int] = .init()
        var completion: Subscribers.Completion<Never>?
        let expect = self.expectation(description: #function)
        sut.sink(receiveCompletion: { completion = $0; expect.fulfill()},
                 receiveValue: { result.append($0) })
            .store(in: &subscriptions)
        wait(for: [expect], timeout: 2)

        XCTAssertTrue(result.contains(4))
        XCTAssertTrue(result.contains(1))
        XCTAssertTrue(result.contains(0))
        XCTAssertNotNil(completion)
    }

    // MARK: - demand

    func testGivenNoWantMoreValuesWhenSubjectEmitsThenDontReceive() {
        let sut = ReplaySubject<Int, Never>(1)

        let subscriber = OneIntSubscriber()
        sut.receive(subscriber: subscriber)
        sut.send(0)
        sut.send(1)
        sut.send(completion: .finished)

        XCTAssertNotNil(subscriber.subscription)
        XCTAssertEqual(subscriber.received, 0)
        XCTAssertEqual(subscriber.completion, Subscribers.Completion.finished)
    }
}

class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    var subscription: Subscription?
    var received: [Int] = .init()
    var completion: Subscribers.Completion<Never>?

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.unlimited)
    }

    func receive(_ input: Int) -> Subscribers.Demand {
        received.append(input)
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {
        self.completion = completion
    }
}

class OneIntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    var subscription: Subscription?
    var received: Int?
    var completion: Subscribers.Completion<Never>?

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))
    }

    func receive(_ input: Int) -> Subscribers.Demand {
        received = input
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        self.completion = completion
    }
}
