//
//  SSUDebugUtils.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/16/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

class SSUDebugUtils: NSObject {
    
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var shouldMockConfig: Bool {
        return ProcessInfo.processInfo.arguments.contains("edu.sonoma.mock.config") && isDebug
    }
}
