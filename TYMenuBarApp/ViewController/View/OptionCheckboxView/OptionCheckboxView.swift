//
//  OptionCheckboxView.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 31.01.2022.
//

import Cocoa

final class OptionCheckboxView: NSView {
    @IBOutlet private weak var checkbox: NSButton!
    var isCheckEnabled: Bool { checkbox.isEnabled }
    private var option: Option?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    @IBAction func checkboxTapped(_ sender: Any) {
        option?.isChecked.toggle()
    }
}

extension OptionCheckboxView {
    func prepareUI(option: Option) {
        self.option = option
        checkbox.title = option.name
        checkbox.state = option.isChecked ? .on : .off
    }
}
