//
//  CircularProgressView.swift
//  PomPadDoMac
//
//  Created by Andrey Mikhaylin on 13.03.2024.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat
    let color: Color
    let lineWidth: Int

    var body: some View {
        ZStack {
            // Background for the progress bar
            Circle()
                .stroke(lineWidth: CGFloat(lineWidth))
                .opacity(0.1)
                .foregroundStyle(color)

            // Foreground or the actual progress bar
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .round, lineJoin: .round))
                .foregroundStyle(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut, value: progress)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.57, color: .blue, lineWidth: 10)
}
