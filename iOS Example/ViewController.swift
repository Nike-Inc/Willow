//
//  ViewController.swift
//
//  Copyright (c) 2015, Christian Noon
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
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
            ("Log Messages", "logMessagesButtonTapped"),
            ("Log Closure Messages", "logClosureMessagesButtonTapped"),
            ("Log Messages on Multiple Threads", "multipleThreadsButtonTapped")
        ]
        
        for (name: String, selector: Selector) in buttonProperties {
            let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
            button.setTitle(name, forState: UIControlState.Normal)
            button.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
            
            self.view.addSubview(button)
            
            button.sizeToFit()
            button.center = CGPoint(x: self.view.center.x, y: self.verticalOffsetPosition)
            self.verticalOffsetPosition += self.buttonVerticalSpacing
        }
    }
    
    // MARK: - Private - UIButton Callback Methods
    
    @objc private func logMessagesButtonTapped() {
        log.debug("Debug Message")
        log.info("Info Message")
        log.event("Event Message")
        log.warn("Warn Message")
        log.error("Error Message")
    }
    
    @objc private func logClosureMessagesButtonTapped() {
        log.debug { "Debug Closure Message" }
        log.info { "Info Closure Message" }
        log.event { "Event Closure Message" }
        log.warn { "Warn Closure Message" }
        log.error { "Error Closure Message" }
    }
    
    @objc private func multipleThreadsButtonTapped() {
        let iterations = 100
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            for index in 1...iterations {
                log.event("Running iteration \(index) of \(iterations) on thread \(NSThread.currentThread())")
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for index in 1...iterations {
                log.info("Running iteration \(index) of \(iterations) on thread \(NSThread.currentThread())")
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            for index in 1...iterations {
                log.warn { "Running iteration \(index) of \(iterations) on thread \(NSThread.currentThread())" }
            }
        }
    }
}
