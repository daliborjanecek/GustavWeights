//
//  ChartView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 28.04.2024.
//

import SwiftUI
import Charts
import GustavUICore

/// Progress of one exercise: one bar per training day, running from the
/// lightest to the heaviest weight logged that day.
struct ChartView: View {
    let exercise: Exercise

    /// Number of training days visible at once. With more days the chart scrolls.
    private let visibleDays = 7
    private let barWidth: CGFloat = 20
    private let barColor = Color("AccentColor")

    /// Label of the tapped day, nil when nothing is selected.
    @State private var selectedLabel: String?

    var body: some View {
        let days = TrainingDay.days(from: exercise.weights)

        if days.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 16) {
                if let selected = days.first(where: { $0.label == selectedLabel }) {
                    selectedDaySummary(selected)
                } else {
                    overallSummary(days)
                }
                chart(days)
                Text(days.count > visibleDays
                     ? "Tap a bar to see the day, swipe to go back in time."
                     : "Tap a bar to see the day.")
                    .font(.sectionFooter)
                    .foregroundStyle(Color.gustavNeutral)
            }
            .padding(.vertical, 8)
            .animation(.easeInOut(duration: 0.2), value: selectedLabel)
        }
    }

    // MARK: - Chart

    private func chart(_ days: [TrainingDay]) -> some View {
        let domain = yDomain(for: days)
        let pr = exercise.personalRecord
        let isScrollable = days.count > visibleDays
        // Keeps a day with a single entry visible as a short pill.
        let pillPadding = (domain.upperBound - domain.lowerBound) * 0.04

        return Chart {
            RuleMark(y: .value("PR", pr))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.gustavPink.opacity(0.6))
                .annotation(position: .top, alignment: .trailing, spacing: 2) {
                    Text("PR")
                        .font(.chartLabel)
                        .foregroundStyle(Color.gustavPink)
                }

            ForEach(days) { day in
                let isSingleValue = day.low == day.top
                RuleMark(x: .value("Day", day.label),
                         yStart: .value("Lowest", isSingleValue ? max(day.low - pillPadding, domain.lowerBound) : day.low),
                         yEnd: .value("Heaviest", isSingleValue ? min(day.top + pillPadding, domain.upperBound) : day.top))
                    .lineStyle(StrokeStyle(lineWidth: barWidth, lineCap: .round))
                    .foregroundStyle(day.top >= pr ? Color.gustavPink : barColor)
                    .opacity(selectedLabel == nil || selectedLabel == day.label ? 1 : 0.3)
                    .accessibilityLabel(day.date.formatted(date: .abbreviated, time: .omitted))
                    .accessibilityValue(day.accessibilityValue)
            }
        }
        .chartYScale(domain: domain)
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gustavNeutral.opacity(0.3))
                AxisValueLabel()
                    .font(.chartLabel)
                    .foregroundStyle(Color.gustavNeutral)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel(collisionResolution: .greedy)
                    .font(.chartLabel)
                    .foregroundStyle(Color.gustavNeutral)
            }
        }
        .chartScrollableAxes(isScrollable ? .horizontal : [])
        .chartXVisibleDomain(length: min(days.count, visibleDays))
        // Open the chart on the most recent days.
        .chartScrollPosition(initialX: days[max(days.count - visibleDays, 0)].label)
        .chartXSelection(value: toggledSelection)
        // A tap selects a day (instead of the default press-and-drag),
        // so the detail stays visible after lifting the finger.
        .chartGesture { proxy in
            SpatialTapGesture().onEnded { value in
                proxy.selectXValue(at: value.location.x)
            }
        }
        .sensoryFeedback(.selection, trigger: selectedLabel)
        .frame(height: 220)
    }

    /// Selecting the already selected day clears the selection.
    private var toggledSelection: Binding<String?> {
        Binding(
            get: { selectedLabel },
            set: { newLabel in
                selectedLabel = (newLabel == selectedLabel) ? nil : newLabel
            }
        )
    }
    
    /// Y axis range rounded to whole tens around all logged values.
    private func yDomain(for days: [TrainingDay]) -> ClosedRange<Double> {
        guard let minValue = days.map(\.low).min(),
              let maxValue = days.map(\.top).max() else {
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

    // MARK: - Summaries

    private func overallSummary(_ days: [TrainingDay]) -> some View {
        HStack(alignment: .top) {
            stat("PR", value: "\(exercise.personalRecord.formattedString(maxDecimalPlaces: 2)) kg")
            stat("PROGRESS", value: progressText(days))
            stat("DAYS", value: "\(days.count)")
        }
    }

    private func selectedDaySummary(_ day: TrainingDay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()).uppercased())
                .font(.sectionHeader)
                .foregroundStyle(Color.gustavNeutral)
            HStack(alignment: .top) {
                stat("TOP", value: "\(day.top.formattedString(maxDecimalPlaces: 2)) kg")
                stat("LOWEST", value: "\(day.low.formattedString(maxDecimalPlaces: 2)) kg")
                stat("ENTRIES", value: "\(day.entries)")
            }
        }
    }

    private func stat(_ title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.sectionHeader)
                .foregroundStyle(Color.gustavNeutral)
            Text(value)
                .font(.statValue)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Difference between the top weight of the last and the first training day.
    private func progressText(_ days: [TrainingDay]) -> String {
        guard days.count > 1, let first = days.first, let last = days.last else { return "–" }
        let difference = last.top - first.top
        let sign = difference > 0 ? "+" : ""
        return "\(sign)\(difference.formattedString(maxDecimalPlaces: 2)) kg"
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundStyle(Color.gustavNeutral)
            Text("NO RECORDS YET")
                .font(.emptyLabel)
            Text("Log a weight on the main screen and your progress shows up here.")
                .font(.emptySubtitle)
                .foregroundStyle(Color.gustavNeutral)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Data

/// All entries of one exercise logged on the same calendar day.
struct TrainingDay: Identifiable {
    /// Start of the day.
    let date: Date
    /// Unique label used as the categorical X value.
    let label: String
    let low: Double
    let top: Double
    let entries: Int

    var id: Date { date }

    var accessibilityValue: String {
        low == top
            ? "\(top.formattedString(maxDecimalPlaces: 2)) kilograms"
            : "\(low.formattedString(maxDecimalPlaces: 2)) to \(top.formattedString(maxDecimalPlaces: 2)) kilograms"
    }

    /// Groups records by calendar day, sorted from the oldest day.
    static func days(from weights: [Weight]) -> [TrainingDay] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: weights) { calendar.startOfDay(for: $0.date) }
        let dates = byDay.keys.sorted()
        // The X axis is categorical, so labels must be unique per day:
        // add the year when the data spans more years.
        let showsYear = Set(dates.map { calendar.component(.year, from: $0) }).count > 1
        let format: Date.FormatStyle = showsYear
            ? .dateTime.day().month(.defaultDigits).year(.twoDigits)
            : .dateTime.day().month(.defaultDigits)

        return dates.compactMap { date in
            let values = byDay[date, default: []].map(\.value)
            guard let low = values.min(), let top = values.max() else { return nil }
            return TrainingDay(date: date,
                               label: date.formatted(format),
                               low: low,
                               top: top,
                               entries: values.count)
        }
    }
}
