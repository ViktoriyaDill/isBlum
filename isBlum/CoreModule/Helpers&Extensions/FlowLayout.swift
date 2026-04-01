//
//  FlowLayout.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 23/03/2026.
//

import Foundation
import SwiftUI

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 12
    let content: (Data.Element) -> Content

    var body: some View {
        _FlowLayout(spacing: spacing, lineSpacing: lineSpacing) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct _FlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    private struct Row {
        var views: [LayoutSubview]
        var sizes: [CGSize]
        var height: CGFloat
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = makeRows(for: subviews, in: proposal.width ?? 0)
        let totalHeight = rows.reduce(0) { $0 + $1.height }
            + CGFloat(max(0, rows.count - 1)) * lineSpacing
        return CGSize(width: proposal.width ?? 0, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = makeRows(for: subviews, in: bounds.width)
        var y = bounds.minY

        for row in rows {
            let rowWidth = row.sizes.reduce(0) { $0 + $1.width }
                + CGFloat(max(0, row.sizes.count - 1)) * spacing
            var x = bounds.minX + (bounds.width - rowWidth) / 2

            for (view, size) in zip(row.views, row.sizes) {
                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }

            y += row.height + lineSpacing
        }
    }

    private func makeRows(for subviews: Subviews, in width: CGFloat) -> [Row] {
        var rows: [Row] = []
        var currentViews: [LayoutSubview] = []
        var currentSizes: [CGSize] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let addedWidth = currentViews.isEmpty
                ? size.width
                : currentWidth + spacing + size.width

            if addedWidth > width && !currentViews.isEmpty {
                rows.append(Row(views: currentViews, sizes: currentSizes, height: currentHeight))
                currentViews = [subview]
                currentSizes = [size]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentViews.append(subview)
                currentSizes.append(size)
                currentWidth = addedWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentViews.isEmpty {
            rows.append(Row(views: currentViews, sizes: currentSizes, height: currentHeight))
        }

        return rows
    }
}
