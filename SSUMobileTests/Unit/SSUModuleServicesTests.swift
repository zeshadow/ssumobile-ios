//
//  SSUModuleServicesTests.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/15/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import XCTest
import Nimble
@testable import SSUMobile

class SSUModuleServicesTests: XCTestCase {
    
    var services: SSUModuleServices!
    
    override func setUp() {
        super.setUp()
        services = SSUModuleServices()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoadNotification() {
        var notificationSent = false
        NotificationCenter.default.addObserver(forName: SSUModulesDidLoadNotification, object: nil, queue: nil) { (notification) in
            notificationSent = true
        }
        
        expect(notificationSent) == false
        services.loadModules()
        expect(notificationSent).toEventually(beTrue())
    }
    
    func testMultipleLoadCalls() {
        // Multiple calls to loadModules should not result in duplicate entries
        
        services.loadModules()
        let count = services.modules.count
        expect(count) > 0
        
        services.loadModules()
        
        expect(self.services.modules.count) == count
    }
}
