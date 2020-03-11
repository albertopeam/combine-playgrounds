//
//  ReplaySubject.swift
//  ReplaySubject
//
//  Created by Alberto Penas Amor on 10/03/2020.
//  Copyright © 2020 com.github.albertopeam. All rights reserved.
//

import Foundation
import Combine

/// ReplaySubject represents a subject that is able to replay sended values prior to any subscriber is connected
public final class ReplaySubject<Output, Failure: Error>: Subject {
    private var buffer = [Output]()
    private let bufferSize: Int
    private var subscriptions = [ReplaySubjectSubscription<Output, Failure>]()
    private var completion: Subscribers.Completion<Failure>?
    private let lock = NSRecursiveLock()

    public init(_ bufferSize: Int = 0) {
        self.bufferSize = bufferSize
    }

    /// Provides this Subject an opportunity to establish demand for any new upstream subscriptions
    public func send(subscription: Subscription) {
        lock.lock(); defer { lock.unlock() }
        subscription.request(.unlimited)
    }

    /// Sends a value to the subscriber.
    public func send(_ value: Output) {
        lock.lock(); defer { lock.unlock() }
        buffer.append(value)
        buffer = buffer.suffix(bufferSize)
        subscriptions.forEach { $0.receive(value) }
    }

    /// Sends a completion signal to the subscriber.
    public func send(completion: Subscribers.Completion<Failure>) {
        lock.lock(); defer { lock.unlock() }
        self.completion = completion
        subscriptions.forEach { subscription in subscription.receive(completion: completion) }
    }

    /// This function is called to attach the specified `Subscriber` to the`Publisher
    public func receive<Downstream: Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
        lock.lock(); defer { lock.unlock() }
        let subscription = ReplaySubjectSubscription<Output, Failure>(downstream: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
        subscriptions.append(subscription)
        subscription.replay(buffer, completion: completion)
    }
}

/// A class representing the connection of a subscriber to a publisher.
public final class ReplaySubjectSubscription<Output, Failure: Error>: Subscription {
    private let downstream: AnySubscriber<Output, Failure>
    private var isCompleted = false
    private var demand: Subscribers.Demand = .none

    public init(downstream: AnySubscriber<Output, Failure>) {
        self.downstream = downstream
    }

    // Tells a publisher that it may send more values to the subscriber.
    public func request(_ newDemand: Subscribers.Demand) {
        demand += newDemand
    }

    public func cancel() {
        isCompleted = true
    }

    public func receive(_ value: Output) {
        guard !isCompleted, demand > 0 else { return }

        demand += downstream.receive(value)
        demand -= 1
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        guard !isCompleted else { return }
        isCompleted = true
        downstream.receive(completion: completion)
    }

    public func replay(_ values: [Output], completion: Subscribers.Completion<Failure>?) {
        guard !isCompleted else { return }
        values.forEach { value in receive(value) }
        if let completion = completion { receive(completion: completion) }
    }
}
