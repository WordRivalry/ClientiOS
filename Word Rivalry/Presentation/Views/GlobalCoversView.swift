//
//  GlobalCovers.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import SwiftUI

enum globalOverlayState: CaseIterable {
    case closed
    case noInternet
    case noIcloudAccount
    case error
}

@Observable class GlobalOverlay {
    var overlay: globalOverlayState = .closed
    static var shared = GlobalOverlay()
}

struct GlobalOverlayView: View {
    @Environment(GlobalOverlay.self) private var globalOverlay
    
    var body: some View {
        Group {
            switch globalOverlay.overlay {
            case .closed:
                EmptyView()
            case .noInternet:
                RoundedRectangle(cornerRadius: 0)
                    .foregroundStyle(.clear)
                    .background(.black.opacity(0.3))
                    .overlay {
                        NoInternetConnectionView()
                    }
            case .noIcloudAccount:
                IcloudStatusMessageView()
            case .error:
                Text("An error occured, recovering...")
            }
        }
        .handleNetworkChanges(
            onDisconnect: {
                globalOverlay.overlay = .noInternet
            }, onConnect:  {
                globalOverlay.overlay = .closed
            }
        )
        .handleIcloudChanges(
            onAvailable: {
                globalOverlay.overlay = .closed
            }, onOther: {
                globalOverlay.overlay = .noIcloudAccount
            }
        )
        .logLifecycle(viewName: "GlobalOverlayView")
    }
}

#Preview { 
    ViewPreview {
        GlobalOverlayView()
    }
}
