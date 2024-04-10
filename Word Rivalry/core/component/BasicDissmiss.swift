//
//  BasicDissmiss.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import SwiftUI
import os.log

/// One size fits all kinda dismiss
struct BasicDissmiss: View {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "BasicDissmiss")
    var text: String = "Dismiss"
    var action: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BasicButton(text: text) {
            // Optionally perform the action before dismissing the view
            action?()
            // Dismiss the view
            dismiss()
            self.logger.debug("BasicDissmiss called")
        }
    }
}

#Preview {
    BasicDissmiss()
}
