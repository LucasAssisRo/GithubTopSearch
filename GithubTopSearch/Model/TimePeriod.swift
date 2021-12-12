//
//  TimePeriod.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Foundation

// MARK: - TimePeriod

enum TimePeriod {
    case day
    case week
    case month

    static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withFullDate
        return dateFormatter
    }()

    var query: String {
        Calendar.current
            .date(
                byAdding: {
                    switch self {
                    case .day: return .weekday
                    case .week: return .weekOfMonth
                    case .month: return .month
                    }
                }(),
                value: -1,
                to: .init()
            )
            .flatMap(Self.dateFormatter.string)!
    }
}
