//
//  IcloudStatusChangeHandlerModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import SwiftUI

struct IcloudStatusChangeHandlerModifier: ViewModifier {
    var onAvailable: (() -> Void)?
    var onOther: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: iCloudService.shared.iCloudStatus) { oldValue, newValue in
                if let newValue = newValue {
                    if newValue == .available  {
                        onAvailable?()
                    } else {
                        onOther?()
                    }
                }
            }
    }
}

extension View {
    func handleIcloudChanges(onAvailable: (() -> Void)? = nil, onOther: (() -> Void)? = nil) -> some View {
        self.modifier(IcloudStatusChangeHandlerModifier(onAvailable: onAvailable, onOther: onOther))
    }
}
