//
//  SSUArticle+CoreDataProperties.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import CoreData


extension SSUArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SSUArticle> {
        return NSFetchRequest<SSUArticle>(entityName: "SSUArticle")
    }

    @NSManaged public var author: String?
    @NSManaged public var category: String?
    @NSManaged public var content: String?
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var link: String?
    @NSManaged public var published: Date?
    @NSManaged public var summary: String?
    @NSManaged public var title: String?

}
