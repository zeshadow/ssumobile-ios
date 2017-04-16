//
//  SSUDebugModule.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/13/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import UIKit

class SSUDebugModule: SSUModuleBase, SSUModuleUI {
    
    @objc(sharedInstance)
    static let instance = SSUDebugModule()
    
    // MARK: SSUModule
    
    var title: String {
        return "Debug"
    }
    
    var identifier: String {
        return "debug"
    }
    
    func setup() {
        
    }
    
    // MARK: SSUModuleUI
    
    func imageForHomeScreen() -> UIImage? {
        return UIImage(named: "debug_icon")
    }
    
    func initialViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Debug", bundle: Bundle(for: type(of: self)))
        return storyboard.instantiateInitialViewController()!
    }
    
    func shouldNavigateToModule() -> Bool {
        return true
    }
}
