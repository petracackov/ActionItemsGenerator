//
//  DateHelper.swift
//  ActionItemsGenerator
//
//  Created by Petra Cackov on 1. 11. 26.
//

import Foundation

/// Formats dates as strings.
final class DateHelper: Sendable {

    static let shared = DateHelper()

    private enum Constants {
        static let fullDateFormat = "dd MMM yyyy, HH:mm"
        static let dateFormat = "dd.MM.yyyy"
        static let fileDateFormat = "dd-MM-yyyy"
        static let monthYearFormat = "MMMM yyyy"
        static let dateWithWeekDayFormat = "EE. d.M"
        static let timeFormat = "h:mm"
        static let hoursFormat = "h a"
        static let amSymbol = "am"
        static let pmSymbol = "pm"
    }

    // MARK: - Formatter

    // CLEANUP: Fixed `dateFormat` strings ignore the user's locale; consider `Date.FormatStyle` / `setLocalizedDateFormatFromTemplate`.
    func fullDateString(date: Date) -> String {
        formatter(dateFormat: Constants.fullDateFormat).string(from: date)
    }

    func dateString(date: Date) -> String {
        formatter(dateFormat: Constants.dateFormat).string(from: date)
    }

    /// `dd-MM-yyyy`, safe to use in file names (no `.` or `/`).
    func dateStringFileFormat(date: Date) -> String {
        formatter(dateFormat: Constants.fileDateFormat).string(from: date)
    }

    /// ISO 8601 with time and the current time zone (`2026-05-15T14:30:00+02:00`), for sending dates to a backend.
    func iso8601String(date: Date) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        isoFormatter.timeZone = .current
        return isoFormatter.string(from: date)
    }

    func monthYearToString(date: Date) -> String {
        formatter(dateFormat: Constants.monthYearFormat).string(from: date)
    }

    func dateWithWeekDayToString(date: Date) -> String {
        formatter(dateFormat: Constants.dateWithWeekDayFormat).string(from: date)
    }

    func timeToString(date: Date) -> String {
        formatter(dateFormat: Constants.timeFormat).string(from: date)
    }

    func hoursToString(date: Date) -> String {
        let dateFormatter = formatter(dateFormat: Constants.hoursFormat)
        dateFormatter.amSymbol = Constants.amSymbol
        dateFormatter.pmSymbol = Constants.pmSymbol
        return dateFormatter.string(from: date)
    }

    // CLEANUP: Fix the `secoonds` parameter typo (breaking change for app call sites).
    // CLEANUP: "h"/"min" are hardcoded user-facing strings; consider `DateComponentsFormatter` or localization.
    func secondsToString(secoonds: Int) -> String {
        let minutes = (secoonds / 60) % 60
        let hours = (secoonds / 3600)
        return "\(hours)h \(minutes)min"
    }

    // MARK: - Private

    /// Creates a fresh formatter per call so `shared` holds no mutable state and is safe to use from any thread.
    private func formatter(dateFormat: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }

}
