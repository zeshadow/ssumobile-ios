//
//  SSUEvent+CoreDataProperties.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/31/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import CoreData


extension SSUEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SSUEvent> {
        return NSFetchRequest<SSUEvent>(entityName: "SSUEvent")
    }

    @NSManaged public var category: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var id: Int32
    @NSManaged public var imgURL: String?
    @NSManaged public var location: String?
    @NSManaged public var organization: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var summary: String?
    @NSManaged public var title: String?

}
