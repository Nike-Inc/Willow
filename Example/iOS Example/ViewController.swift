//
//  ViewController.swift
//
//  Copyright (c) 2015-2016 Nike (https://developer.nike.com)
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
import Network
import UIKit
import Willow

class ViewController: UIViewController {

    // MARK: Helper Types

    private struct Section {
        let title: String
        let items: [Item]
    }

    private struct Item {
        let title: String
        let action: Void -> Void
    }

    // MARK: Properties

    private static let CellIdentifier = "CellID"
    private var sections: [Section] = []
    private var tableView: UITableView!

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

    // MARK: Private - Set Up Methods

    private func setUpInstanceProperties() {
        view.backgroundColor = UIColor.whiteColor()
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
                title: "Network Framework",
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
                            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

                            for _ in range {
                                dispatch_async(queue) {
                                    log.debug { "Logging debug message" }
                                }

                                dispatch_async(queue) {
                                    log.info { "Logging info message" }
                                }

                                dispatch_async(queue) {
                                    log.event { "Logging event message" }
                                }

                                dispatch_async(queue) {
                                    log.warn { "Logging warn message" }
                                }

                                dispatch_async(queue) {
                                    log.error { "Logging error message" }
                                }
                            }
                        }
                    ),
                    Item(
                        title: "Log Messages From Multiple Frameworks",
                        action: {
                            let range = 1...4
                            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

                            for _ in range {
                                dispatch_async(queue) {
                                    log.debug { "Logging debug message" }
                                    log.info { "Logging info message" }
                                    log.event { "Logging event message" }
                                    log.warn { "Logging warn message" }
                                    log.error { "Logging error message" }
                                }

                                dispatch_async(queue) {
                                    Connection.makeSQLCall()
                                    Connection.makeDebugCall()
                                    Connection.makeInfoCall()
                                    Connection.makeEventCall()
                                    Connection.makeWarnCall()
                                    Connection.makeErrorCall()
                                }

                                dispatch_async(queue) {
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
            let tableView = UITableView(frame: view.bounds, style: .Grouped)

            tableView.dataSource = self
            tableView.delegate = self

            tableView.separatorStyle = .SingleLine
            tableView.editing = false

            tableView.allowsSelection = true
            tableView.allowsMultipleSelection = false
            tableView.allowsSelectionDuringEditing = false
            tableView.allowsMultipleSelectionDuringEditing = false

            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ViewController.CellIdentifier)

            view.addSubview(tableView)

            return tableView
        }()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier(ViewController.CellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = item.title

        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.action()

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
