//
//  ViewController.swift
//
//  Copyright (c) 2015-present Nike, Inc. (https://www.nike.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Database
import UIKit
import WebServices
import Willow

class ViewController: UIViewController {

    // MARK: Helper Types

    fileprivate struct Section {
        let title: String
        let items: [Item]
    }

    fileprivate struct Item {
        let title: String
        let action: () -> Void
    }

    struct ExampleLogMessage: LogMessage {
        let name: String
        let attributes: [String: Any]

        init(_ name: String = "", attributes: [String: Any] = [:]) {
            self.name = name
            self.attributes = attributes
        }

        func description() -> String {
            return "Willow Example ~~ \(name): \(attributes)"
        }
    }

    // MARK: Properties

    fileprivate static let cellIdentifier = "CellID"
    fileprivate var sections: [Section] = []
    fileprivate var tableView: UITableView!

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInstanceProperties()
        setUpSections()
        setUpTableView()
    }

    // MARK: Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    // MARK: Private - Setup

    private func setUpInstanceProperties() {
        view.backgroundColor = UIColor.white
        title = "Willow"
    }

    private func setUpSections() {
        sections = [
            Section(
                title: "Example App",
                items: [
                    Item(
                        title: "Log Debug Message",
                        action: { log.debug { "Logging Debug Message" } }
                    ),
                    Item(
                        title: "Log Info Message",
                        action: { log.info { "Logging Info Message" } }
                    ),
                    Item(
                        title: "Log Event Message",
                        action: { log.event { "Logging Event Message" } }
                    ),
                    Item(
                        title: "Log Warn Message",
                        action: { log.warn { "Logging Warn Message" } }
                    ),
                    Item(
                        title: "Log Error Message",
                        action: { log.error { "Logging Error Message" } }
                    )
                ]
            ),
            Section(
                title: "Database Framework",
                items: [
                    Item(
                        title: "Log SQL Message",
                        action: { Connection.makeSQLCall() }
                    ),
                    Item(
                        title: "Log Debug Message",
                        action: { Connection.makeDebugCall() }
                    ),
                    Item(
                        title: "Log Info Message",
                        action: { Connection.makeInfoCall() }
                    ),
                    Item(
                        title: "Log Event Message",
                        action: { Connection.makeEventCall() }
                    ),
                    Item(
                        title: "Log Warn Message",
                        action: { Connection.makeWarnCall() }
                    ),
                    Item(
                        title: "Log Error Message",
                        action: { Connection.makeErrorCall() }
                    )
                ]
            ),
            Section(
                title: "WebServices Framework",
                items: [
                    Item(
                        title: "Log Debug Message",
                        action: { Request.makeDebugRequest() }
                    ),
                    Item(
                        title: "Log Info Message",
                        action: { Request.makeInfoRequest() }
                    ),
                    Item(
                        title: "Log Event Message",
                        action: { Request.makeEventRequest() }
                    ),
                    Item(
                        title: "Log Warn Message",
                        action: { Request.makeWarnRequest() }
                    ),
                    Item(
                        title: "Log Error Message",
                        action: { Request.makeErrorRequest() }
                    )
                ]
            ),
            Section(
                title: "Log Mangling",
                items: [
                    Item(
                        title: "Log App Messages In Parallel",
                        action: {
                            let range = 1...10
                            let queue = DispatchQueue.global()

                            for _ in range {
                                queue.async {
                                    log.debug {
                                        let debugMessage = "Logging debug message"
                                        return debugMessage
                                    }
                                }

                                queue.async {
                                    log.info {
                                        let infoNumber = 1337
                                        return [infoNumber: "Logging info message"]
                                    }
                                }

                                queue.async {
                                    log.event { "Logging event message" }
                                }

                                queue.async {
                                    log.warn { "Logging warn message" }
                                }

                                queue.async {
                                    log.error { "Logging error message" }
                                }
                            }
                        }
                    ),
                    Item(
                        title: "Log Messages From Multiple Frameworks",
                        action: {
                            let range = 1...4
                            let queue = DispatchQueue.global()

                            for _ in range {
                                queue.async {
                                    log.debug { "Logging debug message" }
                                    log.info { "Logging info message" }
                                    log.event { "Logging event message" }
                                    log.warn { "Logging warn message" }
                                    log.error { "Logging error message" }
                                }

                                queue.async {
                                    Connection.makeSQLCall()
                                    Connection.makeDebugCall()
                                    Connection.makeInfoCall()
                                    Connection.makeEventCall()
                                    Connection.makeWarnCall()
                                    Connection.makeErrorCall()
                                }

                                queue.async {
                                    Request.makeDebugRequest()
                                    Request.makeInfoRequest()
                                    Request.makeEventRequest()
                                    Request.makeWarnRequest()
                                    Request.makeErrorRequest()
                                }
                            }
                        }
                    )
                ]
            ),
            Section(
                title: "LogMessages w/Attribtues",
                items: [
                    Item(
                        title: "Log Debug Message",
                        action: {
                            log.debug {
                                let message = "logging debug message"
                                let attributes = [
                                    "Memory leaks": 0,
                                    "Crash rate": 0.0,
                                    "Webservice failure rate": 0.0
                                ]
                                let logMessage = ExampleLogMessage(message, attributes: attributes)
                                return logMessage
                            }
                        }
                    ),
                    Item(
                        title: "Log Info Message",
                        action: {
                            log.info {
                                let message = "logging info message"
                                let attributes: [String: Any] = [
                                    "locale": Locale.current,
                                    "timeZone": TimeZone.current,
                                    "orientation": String(describing: UIDevice.current.orientation),
                                    "deviceModel": UIDevice.current.model,
                                    "deviceName": UIDevice.current.name
                                ]
                                let logMessage = ExampleLogMessage(message, attributes: attributes)
                                return logMessage
                            }
                    }
                    ),
                    Item(
                        title: "Log Event Message",
                        action: {
                            log.event {
                                let message = "logging event message"
                                let attributes: [String: Any] = [
                                    "viewController": self,
                                    "time": Date(),
                                    "event": "clicked Log Event Message button"
                                ]
                                let logMessage = ExampleLogMessage(message, attributes: attributes)
                                return logMessage
                            }
                    }
                    ),
                    Item(
                        title: "Log Warn Message",
                        action: {
                            log.warn {
                                let message = "logging warn message"
                                let attributes: [String: Any] = [
                                    "warnAction": {
                                        func action() {
                                            DispatchQueue.main.async {
                                                guard let window = UIApplication.shared.keyWindow else {
                                                    return
                                                }
                                                guard let rootVC = window.rootViewController else {
                                                    return
                                                }
                                                var currentVC: UIViewController = rootVC
                                                for child in rootVC.childViewControllers {
                                                    if child.isBeingPresented {
                                                        currentVC = child
                                                    }
                                                }
                                                if currentVC.isBeingDismissed {
                                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(50000.0))) { action() }
                                                } else {
                                                    let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                                    currentVC.present(alert, animated: false, completion: nil)
                                                }
                                            }
                                        }
                                        action()
                                    }
                                ]
                                let logMessage = ExampleLogMessage(message, attributes: attributes)
                                return logMessage
                            }
                        }
                    ),
                    Item(
                        title: "Log Error Message",
                        action: {
                            log.error {
                                let message = "logging warn message"
                                let attributes: [String: Any] = [
                                    "code": 1234,
                                    "error": NSError(domain: "com.willow.error", code: 1234, userInfo: [NSLocalizedDescriptionKey: "Error Description", NSLocalizedFailureReasonErrorKey: "Failure due to total system failure", NSLocalizedRecoverySuggestionErrorKey: "Restart the app"])
                                ]
                                let logMessage = ExampleLogMessage(message, attributes: attributes)
                                return logMessage
                            }
                        }
                    )
                ]
            )
        ]
    }

    private func setUpTableView() {
        tableView = {
            let tableView = UITableView(frame: view.bounds, style: .grouped)

            tableView.dataSource = self
            tableView.delegate = self

            tableView.separatorStyle = .singleLine
            tableView.isEditing = false

            tableView.allowsSelection = true
            tableView.allowsMultipleSelection = false
            tableView.allowsSelectionDuringEditing = false
            tableView.allowsMultipleSelectionDuringEditing = false

            tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.cellIdentifier)

            view.addSubview(tableView)

            return tableView
        }()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellIdentifier, for: indexPath)
        cell.textLabel?.text = item.title

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.action()

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
