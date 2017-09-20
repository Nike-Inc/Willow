//
//  ViewController.swift
//
//  Copyright (c) 2015-2017 Nike, Inc. (https://www.nike.com)
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
                        action: { log.debugMessage { "Logging Debug Message" } }
                    ),
                    Item(
                        title: "Log Info Message",
                        action: { log.infoMessage { "Logging Info Message" } }
                    ),
                    Item(
                        title: "Log Event Message",
                        action: { log.eventMessage { "Logging Event Message" } }
                    ),
                    Item(
                        title: "Log Warn Message",
                        action: { log.warnMessage { "Logging Warn Message" } }
                    ),
                    Item(
                        title: "Log Error Message",
                        action: { log.errorMessage { "Logging Error Message" } }
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
                                queue.async { log.debugMessage("Logging debug message") }
                                queue.async { log.infoMessage("Logging info message") }
                                queue.async { log.eventMessage("Logging event message") }
                                queue.async { log.warnMessage("Logging warn message") }
                                queue.async { log.errorMessage("Logging error message") }
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
                                    log.debugMessage("Logging debug message")
                                    log.infoMessage("Logging info message")
                                    log.eventMessage("Logging event message")
                                    log.warnMessage("Logging warn message")
                                    log.errorMessage("Logging error message")
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
