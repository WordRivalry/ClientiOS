//
//  SheetCoordinatorExample.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import SwiftUI

/// Enum representing different sheets related to articles.
enum ArticleSheet: String, ModalEnum {
    case addArticle
    case editArticle
    case selectArticleCategory

    /// Provides a view based on the current sheet context.
    @ViewBuilder
    func view(coordinator: ModalCoordinator<ArticleSheet>) -> some View {
        switch self {
        case .addArticle:
            Text("Add Article")
        case .editArticle:
            Text("Edit Article")
        case .selectArticleCategory:
            Text("Select Article Category")
        }
    }
}

struct SheetCoordinatorExample: View {
    @State var sheetCoordinator = ModalCoordinator<ArticleSheet>()

       var body: some View {
           VStack {
               Button("Add Article") {
                   sheetCoordinator.presentModal(.addArticle)
               }
               Button("Edit Article") {
                   sheetCoordinator.presentModal(.editArticle)
               }
               Button("Article Category") {
                   sheetCoordinator.presentModal(.selectArticleCategory)
               }
           }
               .sheetCoordinating(coordinator: sheetCoordinator)
               .padding()
               .frame(width: 400, height: 300)
       }
}

#Preview {
    ViewPreview {
        SheetCoordinatorExample()
    }
}
