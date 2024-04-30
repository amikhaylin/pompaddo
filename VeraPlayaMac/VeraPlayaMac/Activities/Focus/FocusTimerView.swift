//
//  FocusTimerView.swift
//  VeraPlayaMac
//
//  Created by Andrey Mikhaylin on 30.04.2024.
//

import SwiftUI

struct FocusTimerView: View {
    var body: some View {
        VStack {
            ZStack {
                CircularProgressView(progress: CGFloat(0.5),
                                     color: .blue,
                                     lineWidth: 5)
                .frame(width: 200, height: 200)
                
                Text("25:00")
                    .font(.title)
            }
            
            Button("Start") {
                
            }
            
            Button("Clear") {
                
            }
        }
        .padding()
    }
}

#Preview {
    FocusTimerView()
}
