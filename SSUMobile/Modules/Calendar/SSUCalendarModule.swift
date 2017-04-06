//
//  SSUCalendarModule.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/31/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

class SSUCalendarModule: SSUCoreDataModuleBase, SSUModuleUI {
    
    static let instance = SSUCalendarModule()
    
    // MARK: SSUModule
    
    override static func sharedInstance() -> SSUCalendarModule {
        return instance
    }
    
    func title() -> String {
        return NSLocalizedString("Calendar", comment: "The campus calendar of upcoming events")
    }
    
    func identifier() -> String {
        return "calendar"
    }
    
    override func setup() {
        super.setup()
        let objectModel = model(withName: "Calendar")
        let coordinator = persistentStoreCoordinator(withName: "Calendar", model: objectModel)
        context = self.context(with: coordinator)
        backgroundContext = self.backgroundContext(from: context)
    }
    
    override func updateData(_ completion: (() -> Void)? = nil) {
        SSULogging.logDebug("Update Calendar")
        let lastUpdate = SSUConfiguration.sharedInstance().calendarLastUpdate
        SSUMoonlightCommunicator.getJSONFromPath("events/event", since: lastUpdate) { (response, json, error) in
            if error != nil {
                SSULogging.logError("Error while updating \(self.identifier()): \(error)")
                completion?()
            } else {
                SSUConfiguration.sharedInstance().calendarLastUpdate = Date()
                self.build(json: json) {
                    completion?()
                }
            }
        }
    }
    
    private func build(json: Any, completion: (() -> Void)? = nil) {
        let builder = SSUCalendarBuilder()
        builder.context = backgroundContext
        backgroundContext.perform {
            builder.build(json)
            SSULogging.logDebug("Finish building Calendar")
            completion?()
        }
    }
    
    // MARK: SSUModuleUI
    
    func imageForHomeScreen() -> UIImage? {
        return UIImage(named: "calendar_icon")
    }
    
    func viewForHomeScreen() -> UIView? {
        return nil
    }
    
    func initialViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Calendar_iPhone", bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
    
    func shouldNavigateToModule() -> Bool {
        return true
    }
    
    func showModuleInNavigationBar() -> Bool {
        return false
    }
}
