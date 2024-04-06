//
//  BasicDissmiss.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import SwiftUI

struct BasicDissmiss: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BasicButton(text: "Dismiss") {
            dismiss()
        }
    }
}

#Preview {
    BasicDissmiss()
}
