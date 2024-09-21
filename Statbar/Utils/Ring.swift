//
//  Ring.swift
//  statbar
//
//  Created by Artoo Detoo on 2024/9/21.
//  Copyright © 2024 bsdelf. All rights reserved.
//

public struct Ring<Element> {
    var items: [Element] = []
    var rear = 0
    let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
    }

    mutating func push(item: Element) {
        if (capacity == 0) {
            return
        }
        if (items.count < capacity) {
            items.append(item)
        } else {
            items[rear] = item
        }
        rear += 1
        if (rear >= capacity) {
            rear = 0
        }
    }
}
