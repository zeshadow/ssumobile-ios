//
//  SSUCoreDataModuleBase.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/6/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import CoreData

class SSUCoreDataModuleBase: SSUModuleBase {
    
    var context: NSManagedObjectContext!
    var backgroundContext: NSManagedObjectContext!
    var model: NSManagedObjectModel!
    
    func setupCoreData(modelName: String, storeName: String) {
        model = modelWithName(modelName)
        let coordinator = persistentStoreCoordinatorWithName(storeName: storeName, model: model)
        context = contextWithStoreCoordinator(coordinator)
        backgroundContext = newBackgroundContext(fromParent: context)
    }
 
    func persistentStoreOptions() -> [AnyHashable: Any]? {
        #if DEBUG
        return [NSSQLitePragmasOption: [
                "journal_mode": "DELETE"
            ]]
        #endif
        return nil
    }
    
    
    func modelWithName(_ name: String) -> NSManagedObjectModel {
        let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }
    
    func persistentStoreCoordinatorWithName(storeName: String, model: NSManagedObjectModel) -> NSPersistentStoreCoordinator {
        let filename = "\(storeName).sqlite"
        let directory = SSUApplicationSupportDirectory()!
        let storeURL = directory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: storeURL.path) {
            if let defaultStorePath = Bundle(for: type(of: self)).path(forResource: filename, ofType: nil) {
                do {
                    try FileManager.default.copyItem(atPath: defaultStorePath, toPath: storeURL.path)
                } catch {
                    SSULogging.logError("Unable to copy default DB \(defaultStorePath) to \(storeURL.path)")
                    SSULogging.logError("Starting with an empty database")
                }
            }
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = persistentStoreOptions()
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            // Models may be incompatible, delete the existing store and try again. 
            if FileManager.default.fileExists(atPath: storeURL.path) {
                try! FileManager.default.removeItem(at: storeURL)
            }
            try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        }
        
        excludeURLFromBackup(storeURL)
        
        
        return coordinator
    }
    
    /**
     Creates a new context for use in a background thread, whose persistent store will be the same as
     the `context` property.
     */
    func newBackgroundContext() -> NSManagedObjectContext {
        return newBackgroundContext(fromParent: context)
    }
    
    /**
     Creates a new context for use in a background thread, whose persistent store will be the same as
     the given context
     */
    func newBackgroundContext(fromParent parent: NSManagedObjectContext) -> NSManagedObjectContext {
        let newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        newContext.parent = parent
        return newContext
    }
    
    private func contextWithStoreCoordinator(_ coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }
}
