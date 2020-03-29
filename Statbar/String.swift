//
//  String.swift
//  statbar
//
//  Created by bsdelf on 2020/3/29.
//  Copyright © 2020 bsdelf. All rights reserved.
//

import Foundation

extension String {
    func padStart(targetLength: Int, padString: String = " ") -> String {
        if targetLength >= self.count {
            return self
        }
        let padding = String(repeating: padString, count: targetLength - self.count)
        return padding + self
    }
    
    func padEnd(targetLength: Int, padString: String = " ") -> String {
        if targetLength >= self.count {
            return self
        }
        let padding = String(repeating: padString, count: targetLength - self.count)
        return self + padding
    }
}
