//
//  DispatchQueueExtensions.swift
//  Willow
//
//  Created by RahulKatariya on 23/12/18.
//  Copyright © 2018 Nike. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    func async(group: DispatchGroup?, execute: @escaping () -> Void) {
        if let group = group {
            let dispatchWorkItem = DispatchWorkItem(block: execute)
            async(group: group, execute: dispatchWorkItem)
        } else {
            async(execute: execute)
        }
    }
    
}
