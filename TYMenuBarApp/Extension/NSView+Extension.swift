//
//  NSView+Extension.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 31.01.2022.
//

import Cocoa

extension NSView {
    class func fromNib<T: NSView>() -> T? {
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(NSNib.Name(String(describing: self)), owner: self, topLevelObjects: &topLevelObjects) {
            return topLevelObjects?.first(where: { $0 is NSView } ) as? T
        }
        return nil
    }
}
