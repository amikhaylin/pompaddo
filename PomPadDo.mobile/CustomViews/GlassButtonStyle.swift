//
//  GlassButtonStyle.swift
//  PomPadDo.mobile
//
//  Created by Andrey Mikhaylin on 28.10.2025.
//
import SwiftUI

struct GlassButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
    }
}
