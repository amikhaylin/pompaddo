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
            content.buttonStyle(.borderedProminent)
        } else {
            content.buttonStyle(.bordered)
        }
    }
}
