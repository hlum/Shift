//
//  Logger.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//

import Foundation
import OSLog

public enum Category: String {
    case shift = "Shift"
    case api = "API"
    case company = "Company"
    case salaryDay = "SalaryDay"
    case salary = "Salary"
    case calendar = "Calendar"
    case holiday = "Holiday"
    case general = "General"
}

public enum Logger {
    public static func log(
        _ message: String,
        category: Category,
        type: OSLogType = .default,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logger = os.Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: category.rawValue
        )
        
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        switch type {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        case .fault:
            logger.fault("\(logMessage)")
        default:
            logger.notice("\(logMessage)")
        }
    }
    
    // Convenience methods for different log levels
    public static func debug(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, category: category, type: .debug, file: file, function: function, line: line)
    }
    
    public static func info(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, category: category, type: .info, file: file, function: function, line: line)
    }
    
    public static func error(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, category: category, type: .error, file: file, function: function, line: line)
    }
    
    public static func fault(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, category: category, type: .fault, file: file, function: function, line: line)
    }
    
    public static func warning(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, category: category, type: .default, file: file, function: function, line: line)
    }
}
