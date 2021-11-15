//
//  StatsMonitor.swift
//  Agora Sample
//
//  Created by shaun on 11/15/21.
//

import Foundation
import DequeModule
import Combine

struct StatsMonitor {
    struct Value {
        let current: Int
        let average: Int
    }

    private var deque: Deque<Int> = []

    mutating func receive(value: Int) {
        deque.append(value)

        while deque.count > 10 {
            _ = deque.popFirst()
        }

        let mean = deque.reduce(0, +) / deque.count

        subject.send(Value(current: value, average: mean))
    }

    let subject = PassthroughSubject<Value, Never>()
}
