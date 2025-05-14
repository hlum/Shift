//
//  Logger.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//

import Foundation
import OSLog

public enum Logger {
    public static let standard: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: ""
    )
}
