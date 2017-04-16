//
//  SSUNewsBuilder.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import SwiftyJSON

class SSUNewsBuilder: SSUMoonlightBuilder {
    
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
    
    static func article(withID id: String, inContext: NSManagedObjectContext) -> SSUArticle? {
        if id.isEmpty {
            return nil
        }
        
        let obj = self.object(withEntityName: "SSUArticle", id: id, context: inContext) as? SSUArticle
        // Here we don't know if this is a new object or one that already existed, so make sure it has an id
        obj?.id = id
        
        return obj
    }
    
    private func removeOldArticles() {
        let cutoffDate = Date(timeIntervalSinceNow: -1*SSUNewsArticleFetchDateLimit)
        let predicate = NSPredicate(format: "published <= %@", argumentArray: [cutoffDate])
        SSUNewsBuilder.deleteObjects(withEntityName: "SSUArticle", matching: predicate, context: context)
    }
 
    override func build(_ results: Any!) {
        let json = JSON(results)
        guard let rawArticles = json.array else {
            SSULogging.logError("Expected array in SSUNewsBuilder.build - got \(type(of: results))")
            return
        }
        
        for entry in rawArticles {
            let mode = self.mode(fromJSONData: entry.dictionaryObject ?? [:])
            guard let article = SSUNewsBuilder.article(withID: entry[Keys.id].stringValue, inContext: self.context) else {
                SSULogging.logError("Unable to retrieve or create Article with id: \(entry[Keys.id].stringValue)")
                return
            }
            if mode == .deleted {
                context.delete(article)
                continue
            }
            
            article.initializeWith(json: entry)
        }
        
        removeOldArticles()
        saveContext()
    }
}
