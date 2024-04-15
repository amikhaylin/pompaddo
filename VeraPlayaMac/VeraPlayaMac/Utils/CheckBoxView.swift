//
//  CheckBoxView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 14.04.2024.
//

import SwiftUI

struct CheckBoxView: View {
    @Binding var checked: Bool
    
    var body: some View {
        Button(action: {
            checked.toggle()
        }, label: {
            if checked {
                Image(systemName: "checkmark.square.fill")
            } else {
                Image(systemName: "square")
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @State var checked: Bool = false
    
    return CheckBoxView(checked: $checked)
}
