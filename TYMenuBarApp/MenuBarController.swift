//
//  MenuBarController.swift
//  TYMenuBarApp
//
//  Created by Aytuğ Sevgi on 6.02.2022.
//

import Cocoa

final class MenuBarController: NSObject, NSApplicationDelegate {
    static let shared = MenuBarController()
    private override init() { }

    var statusItem: NSStatusItem!
    private let menu = NSMenu()
    private let popOver = NSPopover()
    private let customTasksMenu = NSMenu()
    private var rootPath = "" //"/Users/aytug.sevgi/Developer/work/ios"
    private let redundantOptions = ["task"]
    private let redundantCommands = ["exec"]
    private weak var viewController: ViewController?
    private weak var outputViewController: OutputViewController?

    var window: NSWindow?

    func applicationDidBecomeActive() {
        self.window = NSApp.mainWindow
    }

    func applicationDidFinishLaunching() {
        if let button = statusItem.button {
            button.image = NSImage(named: "menuIcon")
        }
        menu.delegate = self
        let defaults = UserDefaults.standard
        if let rootPath = defaults.string(forKey: "rootPath") {
            self.rootPath = rootPath
            let names = customTaskNames()
            let tasks = tasksWithOptions(names)

            for task in tasks {
                let item = NSCustomMenuItem(title: "Tuist \(task.name)", action: #selector(AppDelegate.itemTapped(_:)), keyEquivalent: "")
                item.task = task
                if task.isCustom {
                    customTasksMenu.addItem(item)
                } else {
                    menu.addItem(item)
                }
            }
            if !customTasksMenu.items.isEmpty {
                menu.addItem(.separator())
                let customTaskItem = NSMenuItem(title: "Custom tasks", action: nil, keyEquivalent: "")
                customTaskItem.submenu = customTasksMenu
                menu.addItem(customTaskItem)
            }
        }
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Set project path", action: #selector(AppDelegate.setProjectPath), keyEquivalent: "c"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func setProjectPath() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "ViewController")) as? ViewController else { return }
        vc.delegate = self
        viewController = vc
        popOver.contentViewController = vc
        popOver.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)
        vc.prepareUIForSetttings()
    }

    private func tasksWithOptions(_ names: [String]) -> [Task] {
        var tasks = [Task]()
        for name in names {
            let output = shell("tuist exec \(name) --help")
            guard let task = createTaskFromUsage(name: name, output: output, isCustom: true) else { continue }
            tasks.append(task)
        }
        //default tasks
        let output = shell("tuist --help")
        let commandsAndDescriptions = output.sliceMultipleTimes(from: "SUBCOMMANDS:\n", to: "\n\n").first?.components(separatedBy: .newlines)

        let commands = commandsAndDescriptions?.compactMap { commandAndDescription -> String? in
            guard !commandAndDescription.hasPrefix("     ") else { return nil }
            let command = commandAndDescription.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).first

            return (command?.first?.isUppercase ?? true) ? nil : command
        }

        commands?.forEach { command in
            let output = shell("tuist \(command) --help")
            guard let task = createTaskFromUsage(name: command, output: output, isCustom: false) else { return }
            tasks.append(task)
        }
        return tasks
    }

    private func customTaskNames() -> [String] {
        let failedExecOutput = shell("tuist exec tasks")
        let tasks = failedExecOutput.components(separatedBy: "Available tasks are:").last?.replacingOccurrences(of: "\n", with: "")
        var taskList = tasks?.components(separatedBy: ",").compactMap { $0.trimmingCharacters(in: .whitespaces) }
        taskList = taskList?.filter { $0 != "" }
        return taskList ?? .init()
    }

    private func createTaskFromUsage(name: String, output: String, isCustom: Bool) -> Task? {
        guard let usageLine = output.components(separatedBy: .newlines).filter({ $0.contains("USAGE:") }).first,
              !redundantCommands.contains(name) else { return nil }
        let words = usageLine.components(separatedBy: .whitespaces).dropFirst(3)
        var options = [Option]()
        for word in words {
            if word.hasPrefix("<") && word.hasSuffix(">") {
                guard let command = word.sliceMultipleTimes(from: "<", to: ">").first, !redundantOptions.contains(command) else { continue }
                options.append(Option(name: command, isRequired: true, hasParamater: true, hasPrefixTag: false))
            } else if word.hasPrefix("[<") && word.hasSuffix(">]") {
                guard let command = word.sliceMultipleTimes(from: "[<", to: ">]").first, !redundantOptions.contains(command) else { continue }
                options.append(Option(name: command, isRequired: false, hasParamater: true, hasPrefixTag: false))
            } else if word.hasPrefix("[<") && word.hasSuffix(">") {
                guard let command = word.sliceMultipleTimes(from: "[<", to: ">").first, !redundantOptions.contains(command) else { continue }
                options.append(Option(name: command, isRequired: false, hasParamater: true, hasPrefixTag: false))
            } else if word.hasPrefix("[--") && word.hasSuffix("]") {
                guard let command = word.sliceMultipleTimes(from: "[--", to: "]").first, !redundantOptions.contains(command) else { continue }
                options.append(Option(name: command, isRequired: false, hasParamater: false, hasPrefixTag: true))
            } else if word.hasPrefix("[--") {
                let command = String(word.dropFirst(3))
                guard !redundantOptions.contains(command) else { continue }

                options.append(Option(name: command, isRequired: false, hasParamater: true, hasPrefixTag: true))
            }
        }
        return Task(name: name, options: options, isCustom: isCustom)
    }

    func itemTapped(_ sender: NSCustomMenuItem?) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "ViewController")) as? ViewController else { return }
        vc.delegate = self
        viewController = vc
        popOver.contentViewController = vc
        popOver.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)
        vc.prepareUIForTask(task: sender?.task)
    }

    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["--login", "-c", "cd /; cd \(rootPath); " + command]
        task.launchPath = "/bin/bash"
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }

    func executeTuistCommand(_ command: String) {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["--login", "-c", "osascript -e 'tell app \"Terminal\" to activate in front window' -e 'tell application \"Terminal\" to do script \"cd / && cd \(rootPath) && \(command)\" in front window'"]
        task.launchPath = "/bin/bash"

        if #available(macOS 10.13, *) {
            try? task.run()
        } else {
            task.launch()
        }
//        task.terminationHandler = { [weak self] process in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                if task.terminationStatus == 0 {
//                    self?.outputViewController?.addOutputText("\nSuccess!")
//                } else {
//                    self?.outputViewController?.addOutputText("\nError!")
//                }
//                self?.outputViewController?.scrollPageToBottom()
//            }
//            complation()
//        }
//
//        pipe.fileHandleForReading.readabilityHandler = { [weak self] file in
//            while task.isRunning {
//                let data = pipe.fileHandleForReading.readData(ofLength: 100)
//                if var output = String(data: data, encoding: .ascii) {
//                    output = output.trimmingCharacters(in: .newlines)
//                    DispatchQueue.main.async {
//                        self?.outputViewController?.addOutputText(output)
//                    }
//                }
//            }
//        }
    }

    private func createWindow() {
        window?.close()
        window = NSApp.mainWindow
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 380),
            styleMask: [.miniaturizable, .resizable, .titled, .fullSizeContentView],
                    backing: .buffered, defer: false)
        window?.minSize = NSSize(width: 380, height: 250)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let outputViewController = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "OutputViewController")) as? OutputViewController else { return }
        self.outputViewController = outputViewController
    }
}

extension MenuBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        popOver.close()
    }
}

extension MenuBarController: ViewControllerDelegate {
    func rootPathSelected(path: String) {
        popOver.close()
        UserDefaults.standard.set(path, forKey: "rootPath")
        menu.removeAllItems()
        customTasksMenu.removeAllItems()
        applicationDidFinishLaunching()
    }

    func runButtonTapped(task: Task) {
        popOver.close()
//        createWindow()
//        window?.center()
//        window?.delegate = self
//        window?.title = "Output of tuist \(task.name)"
//        NSApp.activate(ignoringOtherApps: true)
//        window?.makeKeyAndOrderFront(self)
//        window?.contentViewController = outputViewController
//        window?.isReleasedWhenClosed = false
        var command = "tuist \(task.isCustom ? "exec " : "")\(task.name)"
        for option in task.options {
            option.input = option.input.trimmingCharacters(in: .whitespaces)
            if option.isCheckbox, option.isChecked {
                command += " --\(option.name)"
            } else if !option.input.isEmpty {
                if option.hasPrefixTag {
                    command += " --\(option.name)"
                }
                command += " \(option.input)"
            }
        }
        //outputViewController?.addOutputText("Running Command: \(command)\n")

        executeTuistCommand(command)
//        { [weak self] in
//            DispatchQueue.main.async {
//                self?.viewController?.setInfoLabelText("")
//                self?.window?.styleMask.insert(.closable)
//                self?.outputViewController?.scrollPageToBottom()
//            }
//        }
    }
}

extension MenuBarController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        //outputViewController = nil
        window = nil
    }
}
