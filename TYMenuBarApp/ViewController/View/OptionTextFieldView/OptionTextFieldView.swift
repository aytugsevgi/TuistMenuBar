//
//  OptionTextFieldView.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 31.01.2022.
//

import Cocoa

final class OptionTextFieldView: NSView {
    @IBOutlet private weak var label: NSTextField!
    @IBOutlet private weak var textField: NSTextField!
    private var option: Option?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

extension OptionTextFieldView {
    private var inputText: String { textField.stringValue }

    func prepareUI(option: Option) {
        self.option = option
        label.stringValue = option.name
        textField.stringValue = option.input
        textField.delegate = self
    }
}

extension OptionTextFieldView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        option?.input = inputText
    }
}
