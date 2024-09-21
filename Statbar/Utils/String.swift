//
//  String.swift
//  statbar
//
//  Created by bsdelf on 2020/3/29.
//  Copyright © 2024 bsdelf. All rights reserved.
//

import Foundation

func getPadding(input: String, targetLength: Int, padString: String) -> String {
    if (input.count >= targetLength || padString.isEmpty) {
        return ""
    }
    let padCount = (targetLength - input.count) / padString.count
    let remCount = targetLength - input.count - padString.count * padCount
    let padding = String(repeating: padString, count: padCount) + padString.prefix(remCount)
    return padding
}

public extension String {
    func padStart(targetLength: Int, padString: String = " ") -> String {
        let padding = getPadding(input: self, targetLength: targetLength, padString: padString)
        return padding + self
    }
    
    func padEnd(targetLength: Int, padString: String = " ") -> String {
        let padding = getPadding(input: self, targetLength: targetLength, padString: padString)
        return self + padding
    }
}
