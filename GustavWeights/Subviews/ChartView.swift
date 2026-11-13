//
//  ChartView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 28.04.2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    @Bindable var exercise: Exercise

    /// With more training days than this the chart scrolls horizontally.
    private let scrollableDaysThreshold = 5

    var body: some View {
        let dailyWeights = getDailyValues()
        let domain = getDomain()
        let pillPadding = (domain.upperBound - domain.lowerBound) * 0.08
        let showsYear = spansMoreYears(dailyWeights)

        Chart(dailyWeights) { dailyWeight in
            let label = formatDate(dailyWeight.date, showsYear: showsYear)
            let isSingleValue = dailyWeight.range.lowerBound == dailyWeight.range.upperBound
            // A day with a single entry is drawn as a short pill,
            // otherwise the bar would have zero height.
            let lower = isSingleValue
                ? max(dailyWeight.range.lowerBound - pillPadding, domain.lowerBound)
                : dailyWeight.range.lowerBound
            let upper = isSingleValue
                ? min(dailyWeight.range.upperBound + pillPadding, domain.upperBound)
                : dailyWeight.range.upperBound

            RuleMark(x: .value("Date", label),
                     yStart: .value("Lower", lower),
                     yEnd: .value("Higher", upper))
                .lineStyle(StrokeStyle(lineWidth: 20))
                .cornerRadius(20)
        }
        .chartScrollableAxes(dailyWeights.count > scrollableDaysThreshold ? .horizontal : [])
        .chartScrollPosition(initialX: formatDate(dailyWeights.last?.date ?? .now, showsYear: showsYear))
        .chartXAxis(.visible)
        .chartYAxis(.visible)
        .chartYScale(domain: domain)
        .frame(height: 200)
        .padding()
    }

    struct DailyWeights: Identifiable {
        var id: Date { date }
        var range: ClosedRange<Double>
        /// Start of the training day.
        var date: Date
    }

    /// Y axis range rounded to whole tens around all logged values.
    func getDomain() -> ClosedRange<Double> {
        let values = exercise.weights.map(\.value)
        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0...100
        }
        var lower = (minValue / 10).rounded(.down) * 10
        var upper = (maxValue / 10).rounded(.up) * 10
        if lower == upper {
            // All values are the same round number, e.g. 100 kg.
            lower = max(lower - 10, 0)
            upper += 10
        }
        return lower...upper
    }

    /// One entry per training day with the lightest and heaviest weight of that day,
    /// sorted from the oldest day.
    func getDailyValues() -> [DailyWeights] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: exercise.weights) { calendar.startOfDay(for: $0.date) }

        return byDay.compactMap { day, weights in
            let values = weights.map(\.value)
            guard let minValue = values.min(), let maxValue = values.max() else { return nil }
            return DailyWeights(range: minValue...maxValue, date: day)
        }
        .sorted { $0.date < $1.date }
    }

    private func spansMoreYears(_ dailyWeights: [DailyWeights]) -> Bool {
        guard let first = dailyWeights.first, let last = dailyWeights.last else { return false }
        let calendar = Calendar.current
        return calendar.component(.year, from: first.date) != calendar.component(.year, from: last.date)
    }

    /// X axis is categorical, so the label has to be unique per day.
    /// When the data spans more years, the year is added,
    /// otherwise e.g. 10. 03. 2024 and 10. 03. 2025 would share one bar.
    func formatDate(_ date: Date, showsYear: Bool) -> String {
        let formatter = showsYear ? Self.dayMonthYearFormatter : Self.dayMonthFormatter
        return formatter.string(from: date)
    }

    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MM."
        return formatter
    }()

    private static let dayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MM. yy"
        return formatter
    }()
}
