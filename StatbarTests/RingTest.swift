//
//  RingTest.swift
//  StatbarTests
//
//  Created by Artoo Detoo on 2024/9/21.
//  Copyright © 2024 bsdelf. All rights reserved.
//

import Testing
@testable import Statbar

struct RingTest {

    @Test("Push int item", arguments: [
        (0, [1], []),
        // cap = 1
        (1, [1], [1]),
        (1, [1,2], [2]),
        (1, [1,2,3], [3]),
        // cap = 2
        (2, [1], [1]),
        (2, [1,2], [1,2]),
        (2, [1,2,3], [3,2]),
        (2, [1,2,3,4], [3,4])
    ]) func push(capacity: Int, pushSeq: [Int], expected:[Int]) async throws {
        var ring = Ring<Int>(capacity: capacity)
        for item in pushSeq {
            ring.push(item: item)
        }
        #expect(ring.items == expected)
    }

}
