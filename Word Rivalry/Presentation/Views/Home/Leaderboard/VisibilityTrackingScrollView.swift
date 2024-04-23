//
//  VisScrollView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

//MIT License
//
//Copyright (c) 2022 Elegant Chaos Limited
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI

public enum VisibilityChange {
    case hidden
    case shown
}

public class VisibilityTracker<ID: Hashable>: ObservableObject {
    /// The global bounds of the container view.
    public var containerBounds: CGRect
    
    /// Dictionary containing the offset of every visible view.
    public var visibleViews: [ID:CGFloat]
    
    /// Ids of the visible views, sorted by offset.
    /// The first item is the top view, the last one, the bottom view.
    public var sortedViewIDs: [ID]
    
    /// Action to perform when a view becomes visible or is hidden.
    public var action: Action
    
    /// The id of the top visible view.
    public var topVisibleView: ID? { sortedViewIDs.first }
    
    /// The id of the bottom visible view.
    public var bottomVisibleView: ID? { sortedViewIDs.last }

    /// Action callback signature.
    public typealias Action = (ID, VisibilityChange, VisibilityTracker<ID>) -> ()

    public init(action: @escaping Action) {
        self.containerBounds = .zero
        self.visibleViews = [:]
        self.sortedViewIDs = []
        self.action = action
    }
    
    public func reportContainerBounds(_ bounds: CGRect) {
        containerBounds = bounds
    }
    
    public func reportContentBounds(_ bounds: CGRect, id: ID) {
        let topLeft = bounds.origin
        let size = bounds.size
        let bottomRight = CGPoint(x: topLeft.x + size.width, y: topLeft.y + size.height)
        let isVisible = containerBounds.contains(topLeft) || containerBounds.contains(bottomRight)
        let wasVisible = visibleViews[id] != nil
        
        

        if isVisible {
            visibleViews[id] = bounds.origin.y - containerBounds.origin.y
            sortViews()
            if !wasVisible {
                action(id, .shown, self)
            }
        } else {
            if wasVisible {
                visibleViews.removeValue(forKey: id)
                sortViews()
                action(id, .hidden, self)
            }
        }
    }
    
    func sortViews() {
        let sortedPairs = visibleViews.sorted(by: { $0.1 < $1.1 })
        sortedViewIDs = sortedPairs.map { $0.0 }
    }
}

struct ContentVisibilityTrackingModifier<ID: Hashable>: ViewModifier {
    @EnvironmentObject var visibilityTracker: VisibilityTracker<ID>
    
    let id: ID
    
    func body(content: Content) -> some View {
        content
            .id(id)
            .background(
                GeometryReader { proxy in
                    report(proxy: proxy)
                }
            )
    }
    
    func report(proxy: GeometryProxy) -> Color {
        visibilityTracker.reportContentBounds(proxy.frame(in: .global), id: id)
        return Color.clear
    }
}

public extension View {
    func trackVisibility<ID: Hashable>(id: ID) -> some View {
        self
            .modifier(ContentVisibilityTrackingModifier(id: id))
    }
}

public struct VisibilityTrackingScrollView<Content, ID>: View where Content: View, ID: Hashable {
    @ViewBuilder let content: Content
    
    @State var visibilityTracker: VisibilityTracker<ID>
    
    public init(action: @escaping VisibilityTracker<ID>.Action, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._visibilityTracker = .init(initialValue: VisibilityTracker<ID>(action: action))
    }
    
    public var body: some View {
        ScrollView {
            content
                .environmentObject(visibilityTracker)
        }
        .background(
            GeometryReader { proxy in
                report(proxy: proxy)
            }
        )
    }
    
    func report(proxy: GeometryProxy) -> Color {
        visibilityTracker.reportContainerBounds(proxy.frame(in: .global))
        return Color.clear
    }

}
