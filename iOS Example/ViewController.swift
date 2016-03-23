//
//  ViewController.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import UIKit
import Willow

class ViewController: UIViewController {

    // MARK: - Private - Properties

    private let buttonVerticalSpacing: CGFloat = 40.0
    private var verticalOffsetPosition: CGFloat = 120.0

    // MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInstanceProperties()
        setUpButtons()
    }

    // MARK: - Private - Set Up Methods

    private func setUpInstanceProperties() {
        self.title = "Willow Example"
    }

    private func setUpButtons() {
        let buttonProperties: [(name: String, selector: Selector)] = [
            ("Log Debug Message", #selector(ViewController.logDebugMessageButtonTapped)),
            ("Log Info Message", #selector(ViewController.logInfoMessageButtonTapped)),
            ("Log Event Message", #selector(ViewController.logEventMessageButtonTapped)),
            ("Log Warn Message", #selector(ViewController.logWarnMessageButtonTapped)),
            ("Log Error Message", #selector(ViewController.logErrorMessageButtonTapped)),
            ("Log All Messages", #selector(ViewController.logAllMessagesButtonTapped)),
            ("Log Messages on Multiple Threads", #selector(ViewController.multipleThreadsButtonTapped))
        ]

        for (name, selector) in buttonProperties {
            let button = UIButton(type: .System)
            button.setTitle(name, forState: UIControlState.Normal)
            button.addTarget(self, action: selector, forControlEvents: .TouchUpInside)

            self.view.addSubview(button)

            button.sizeToFit()
            button.center = CGPoint(x: self.view.center.x, y: self.verticalOffsetPosition)
            self.verticalOffsetPosition += self.buttonVerticalSpacing
        }
    }

    // MARK: - Private - UIButton Callback Methods

    @objc private func logDebugMessageButtonTapped() {
        log.debug { "Debug Message" }
    }

    @objc private func logInfoMessageButtonTapped() {
        log.info { "Info Message" }
    }

    @objc private func logEventMessageButtonTapped() {
        log.event { "Event Message" }
    }

    @objc private func logWarnMessageButtonTapped() {
        log.warn { "Warn Message" }
    }

    @objc private func logErrorMessageButtonTapped() {
        log.error { "Error Message" }
    }

    @objc private func logAllMessagesButtonTapped() {
        log.debug { "Debug Message" }
        log.info { "Info Message" }
        log.event { "Event Message" }
        log.warn { "Warn Message" }
        log.error { "Error Message" }
    }

    @objc private func multipleThreadsButtonTapped() {
        let iterations = 100

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            for index in 1...iterations {
                log.event { "Running iteration \(index) of \(iterations) on thread \(NSThread.currentThread())" }
            }
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for index in 1...iterations {
                log.info { "Running iteration \(index) of \(iterations) on thread \(NSThread.currentThread())" }
            }
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            for index in 1...iterations {
                log.warn { "Running iteration \(index) of \(iterations) on thread \(NSThread.currentThread())" }
            }
        }
    }
}
