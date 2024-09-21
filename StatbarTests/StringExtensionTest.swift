//
//  StringExtensionTest.swift
//  StatbarTests
//
//  Created by Artoo Detoo on 2024/9/21.
//  Copyright © 2024 bsdelf. All rights reserved.
//

import Testing
@testable import Statbar

struct StringExtensionTest {

    @Test("Pads a string from the start", arguments: [
        ("", 0, "", ""),
        ("a", 0, "", "a"),
        ("a", 1, "", "a"),
        ("a", 2, "", "a"),
        ("a", 2, " ", " a"),
        ("a", 2, ".", ".a"),
        ("a", 5, "12", "1212a"),
        ("a", 6, "12", "12121a"),
    ]) func padStart(str: String, targetLength: Int, padString: String, expected: String) async throws {
        let actual = str.padStart(targetLength: targetLength, padString: padString)
        #expect(actual == expected)
    }

    @Test("Pads a string at the end", arguments: [
        ("", 0, "", ""),
        ("a", 0, "", "a"),
        ("a", 1, "", "a"),
        ("a", 2, "", "a"),
        ("a", 2, " ", "a "),
        ("a", 2, ".", "a."),
        ("a", 5, "12", "a1212"),
        ("a", 6, "12", "a12121"),
    ]) func padEnd(str: String, targetLength: Int, padString: String, expected: String) async throws {
        let actual = str.padEnd(targetLength: targetLength, padString: padString)
        #expect(actual == expected)
    }

}
