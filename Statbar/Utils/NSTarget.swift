//
//  NSTarget.swift
//  Statbar
//
//  Created by Artoo Detoo on 2024/9/21.
//  Copyright © 2024 bsdelf. All rights reserved.
//

import Cocoa

final class NSTarget: NSObject {
    private let callback: () -> ()

    init(callback: @escaping () -> ()) {
        self.callback = callback
        super.init()
    }

    @objc func action() {
        self.callback()
    }
}
