//
//  SomeViewController.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 22.01.2022.
//

import Cocoa

final class OutputViewController: NSViewController {
    @IBOutlet private var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func scrollPageToBottom() {
        textView.scrollToEndOfDocument(self)
    }

    func addOutputText(_ text: String) {
        textView.string += text
        textView.scrollPageDown(self)
    }
}
