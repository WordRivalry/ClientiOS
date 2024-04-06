//
//  DescriptionView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import SwiftUI

struct DescriptionView: View {
    var description: String
    var body: some View {
        Text(description)
            .font(.callout)
    }
}

#Preview {
    DescriptionView(description: "Yup")
}
