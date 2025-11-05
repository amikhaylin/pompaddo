//
//  Cursor.swift
//  PomPadDo
//
//  Created by Andrey Mikhaylin on 05.11.2025.
//

import SwiftUI

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
