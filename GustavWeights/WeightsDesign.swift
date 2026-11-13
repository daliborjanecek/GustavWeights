//
//  WeightsDesign.swift
//  GustavWeights
//
//  Text styles specific to Gustav Weights. They use the Martian fonts
//  registered by GustavUI (GustavDesign.registerFonts()); shared styles
//  such as .bodyNumber, .gustavBody or .sectionHeader come from GustavUICore.
//

import SwiftUI
import GustavUICore

extension Font {
    /// Exercise name on the card. Huge on purpose, scaled down to fit the width.
    static let exerciseTitle = Font.custom("MartianMono-Bold", size: 500)
    /// Big numbers: PR on the card and the value typed into the input sheets.
    static let weightsValue = Font.custom("MartianMono-Bold", size: 30, relativeTo: .title)
    /// Title of the empty state on the main screen.
    static let weightsEmptyTitle = Font.custom("MartianMono-Bold", size: 22, relativeTo: .title2)
    /// Small labels such as the NEW PR! badge.
    static let weightsBadge = Font.custom("MartianMono-Bold", size: 15, relativeTo: .caption)
    /// Numbers in the summary above the progress chart.
    static let statValue = Font.custom("MartianMono-Bold", size: 20, relativeTo: .title3)
    /// Axis labels and small numbers in the progress chart.
    static let chartLabel = Font.custom("MartianMono-Regular", size: 10, relativeTo: .caption2)
}
