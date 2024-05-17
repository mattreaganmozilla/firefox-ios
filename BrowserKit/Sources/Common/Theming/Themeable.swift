// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

public protocol Themeable: ThemeUUIDIdentifiable, AnyObject {
    var themeManager: ThemeManager { get }
    var themeObserver: NSObjectProtocol? { get set }
    var notificationCenter: NotificationProtocol { get set }

    func listenForThemeChange(_ subview: UIView)
    func applyTheme()
}

public protocol ThemeUUIDIdentifiable: AnyObject {
    var currentWindowUUID: WindowUUID? { get }
}

extension Themeable {
    public func listenForThemeChange(_ subview: UIView) {
        let mainQueue = OperationQueue.main
        themeObserver = notificationCenter.addObserver(name: .ThemeDidChange,
                                                       queue: mainQueue) { [weak self] notification in
            guard let self else { return }            
            let changedUUID = notification.windowUUID
            let windowUUID = self.currentWindowUUID
            guard changedUUID.isNilOrUnavailable || windowUUID == changedUUID else { return }

            self.applyTheme()
            let theme = themeManager.currentTheme(for: windowUUID)
            self.updateThemeApplicableSubviews(subview, with: theme)
        }
    }

    public func updateThemeApplicableSubviews(_ view: UIView, with theme: Theme) {
        let themeViews = getAllSubviews(for: view, ofType: ThemeApplicable.self)
        themeViews.forEach { $0.applyTheme(theme: theme) }
    }

    public func getAllSubviews<T>(for view: UIView, ofType type: T.Type) -> [T] {
        var secondLevelSubviews = [T]()
        let firstLevelSubviews: [T] = view.subviews.compactMap { childView in
            secondLevelSubviews = secondLevelSubviews + getAllSubviews(for: childView, ofType: type)
            return childView as? T
        }
        return firstLevelSubviews + secondLevelSubviews
    }
}
