//
//  ConditionalButtonStyle.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 29.07.2025.
//
import SwiftUI

struct ConditionalButtonStyle: ViewModifier {
    let condition: Bool
    
    func body(content: Content) -> some View {
        if condition {
            if #available(iOS 26.0, *) {
                content.buttonStyle(.glassProminent)
            } else {
                content.buttonStyle(.borderedProminent)
            }
        } else {
            if #available(iOS 26.0, *) {
                content.buttonStyle(.glass)
            } else {
                content.buttonStyle(.bordered)
            }
        }
    }
}
