//
//  AccessoryView.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 30.01.2022.
//

import Cocoa

protocol AccessoryViewDelegate: NSObject {
    func runButtonTapped(task: Task)
}

final class AccessoryView: NSView {
    @IBOutlet private weak var containerView: NSView!
    @IBOutlet private weak var stackView: NSStackView!
    @IBOutlet private weak var label: NSTextField!
    @IBOutlet private weak var runButton: NSButton!
    @IBOutlet private weak var infoLabel: NSTextField!
    weak var delegate: AccessoryViewDelegate?
    private var task: Task?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    @IBAction private func runButtonTapped(_ sender: NSButton) {
        guard let task = task else {
//            infoLabel.textColor = .yellow
//            infoLabel.stringValue = "Can't found any task!"
            return
        }
//        infoLabel.textColor = .green
//        infoLabel.stringValue = "Command is running.."
        delegate?.runButtonTapped(task: task)
    }

    func prepareUI(task: Task?) {
        guard let task = task else { return }
        self.task = task
        label.stringValue = "Tuist \(task.name)"
        for option in task.options {
            var title = option.name
            if option.isCheckbox {
                let view = OptionCheckboxView.fromNib() as? OptionCheckboxView
                view?.prepareUI(option: option)
                guard let view = view else { return }
                stackView.addView(view, in: .center)
            } else {
                title = option.isRequired ? "*" + title : title
                let view = OptionTextFieldView.fromNib() as? OptionTextFieldView
                view?.prepareUI(option: option)
                guard let view = view else { return }
                stackView.addView(view, in: .center)
            }
        }
    }

    func setInfoLabelText(_ text: String) {
        infoLabel.stringValue = text
    }
}
