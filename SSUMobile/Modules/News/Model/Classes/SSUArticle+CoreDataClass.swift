//
//  SSUArticle+CoreDataClass.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc(SSUArticle)
public class SSUArticle: SSUNewsObject, SSUJSONInitializable {
    
    private struct Keys {
        static let id = "article_id"
        static let author = "author"
        static let category = "category"
        static let title = "title"
        static let imageURL = "image_url"
        static let summary = "summary"
        static let content = "content"
        static let link = "url"
        static let publishDate = "publish_date"
    }
    
    func initializeWith(dict: [AnyHashable : Any]) {
        initializeWith(json: JSON(dict))
    }
    
    func initializeWith(json: JSON) {
        id = json[Keys.id].string
        author = json[Keys.author].string
        category = json[Keys.category].string
        title = json[Keys.title].string
        imageURL = json[Keys.imageURL].string
        summary = json[Keys.summary].string
        content = json[Keys.content].string
        link = json[Keys.link].string
        if let retrievedLink = link, retrievedLink.isEmpty {
           link = nil
        }
        
        if let date = SSUDateUtils.dateFrom(iso8601String: json[Keys.publishDate].stringValue) {
            published = date
        } else {
            SSULogging.logError("Unable to parse published date: \(json[Keys.publishDate].stringValue)")
            published = nil
        }
    }
}
