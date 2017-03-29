//
//  SSUNewsObject+CoreDataProperties.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import CoreData


extension SSUNewsObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SSUNewsObject> {
        return NSFetchRequest<SSUNewsObject>(entityName: "SSUNewsObject");
    }

    @NSManaged public var sectionName: String?

}
