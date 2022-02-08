//
//  ViewController.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 22.01.2022.
//

import Cocoa

protocol ViewControllerDelegate: NSObject {
    func runButtonTapped(task: Task)
    func rootPathSelected(path: String)
}

final class ViewController: NSViewController {
    @IBOutlet weak var stackView: NSStackView!
    weak var delegate: ViewControllerDelegate?
    weak var accessoryView: AccessoryView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func prepareUIForTask(task: Task?) {
        let subView = AccessoryView.fromNib() as! AccessoryView
        subView.delegate = self
        subView.prepareUI(task: task)
        stackView.addView(subView, in: .top)
        preferredContentSize = subView.frame.size
        accessoryView = subView
    }

    func prepareUIForSetttings() {
        let subView = SettingView.fromNib() as! SettingView
        subView.delegate = self
        stackView.addView(subView, in: .top)
        preferredContentSize = subView.frame.size
    }

    func setInfoLabelText(_ text: String) {
        accessoryView?.setInfoLabelText(text)
    }
}

extension ViewController: AccessoryViewDelegate {
    func runButtonTapped(task: Task) {
        delegate?.runButtonTapped(task: task)
    }
}

extension ViewController: SettingViewDelegate {
    func rootPathSelected(path: String) {
        delegate?.rootPathSelected(path: path)
    }
}
