//
//  AppDelegate.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 22.01.2022.
//

import Cocoa

extension String {
    func sliceMultipleTimes(from: String, to: String) -> [String] {
        components(separatedBy: from).dropFirst().compactMap { sub in
            (sub.range(of: to)?.lowerBound).flatMap { endRange in
                String(sub[sub.startIndex ..< endRange])
            }
        }
    }
}

class NSCustomMenuItem: NSMenuItem {
    var task: Task?
}

class Task: NSObject {
    let name: String
    let options: [Option]
    let isCustom: Bool

    init(name: String, options: [Option], isCustom: Bool) {
        self.name = name
        self.options = options
        self.isCustom = isCustom
    }
}

class Option: NSObject {
    let name: String
    let isRequired: Bool
    let hasParamater: Bool
    let hasPrefixTag: Bool

    init(name: String, isRequired: Bool, hasParamater: Bool, hasPrefixTag: Bool) {
        self.name = name
        self.isRequired = isRequired
        self.hasParamater = hasParamater
        self.hasPrefixTag = hasPrefixTag
    }

    var isCheckbox: Bool { !hasParamater && hasPrefixTag }
    var input: String = ""
    var isChecked: Bool = false
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let controller = MenuBarController.shared

    var window: NSWindow?

    func applicationDidBecomeActive(_ notification: Notification) {
        controller.applicationDidBecomeActive()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        controller.statusItem = statusItem
        controller.applicationDidFinishLaunching()
    }

    @objc func itemTapped(_ sender: NSCustomMenuItem?) {
        controller.itemTapped(sender)
    }

    @objc func setProjectPath() {
        controller.setProjectPath()
    }
}
