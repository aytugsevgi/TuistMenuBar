//
//  SettingView.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 7.02.2022.
//

import Cocoa

protocol SettingViewDelegate: NSObject {
    func rootPathSelected(path: String)
}
final class SettingView: NSView {
    @IBOutlet private weak var pathTextField: NSTextField!
    weak var delegate: SettingViewDelegate?
    private var selectedPath: String?
    @IBOutlet private weak var infoLabel: NSTextField!

    @IBAction func selectFolderButtonTapped(_ sender: NSButton) {
        infoLabel.stringValue = ""
        let dialog = NSOpenPanel();

        dialog.title = "Select a project root path"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if let path = dialog.url?.path {
                selectedPath = path
                pathTextField.stringValue = path
                print(path)
            } else {
                infoLabel.stringValue = "Invalid path"
                pathTextField.stringValue = ""
            }
        }
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let selectedPath = selectedPath, !selectedPath.isEmpty else {
            infoLabel.stringValue = "Path can't be empty!"
            return
        }
        delegate?.rootPathSelected(path: selectedPath)
    }
}
