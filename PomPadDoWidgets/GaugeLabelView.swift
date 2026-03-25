//
//  GaugeLabelView.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 24.03.2026.
//

import SwiftUI

struct GaugeLabelView: View {
    @State var tasksCount: Int = 0
    
    var body: some View {
        if tasksCount > 0 {
            Text("\(tasksCount)")
        } else {
            Image(systemName: "checkmark")
        }
    }
}

#Preview {
    GaugeLabelView()
    GaugeLabelView(tasksCount: 10)
}
