//
//  ClockView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import SwiftUI

struct ClockView: View {
    @Binding var timeleft: String
    
    var body: some View {
        Text(timeleft)
            .font(.title)
    }
}
 
#Preview {
    ClockView(timeleft: .constant("15"))
}
