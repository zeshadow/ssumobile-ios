//
//  SSUArticleTests.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/16/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import XCTest
import Nimble
import SwiftyJSON
@testable import SSUMobile

class SSUArticleTests: XCTestCase {
    
    var article: SSUArticle!
    
    override func setUp() {
        super.setUp()
        article = SSUArticle(entity: SSUArticle.entity(), insertInto: nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJSONInitialization() {
        let dict: [String:Any?] = [
            "id": 139,
            "created": "2017-04-14T19:00:06Z",
            "modified": "2017-04-16T22:00:02Z",
            "deleted": nil,
            "article_id": "tag:www.sonoma.edu,2017:/newscenter//77.30937",
            "publish_date": "2017-04-14T18:02:32Z",
            "title": "Vocal Instructor Zachary Gordin Performs Hahn's Favorite Pieces",
            "url": "http://www.sonoma.edu/newscenter/2017/04/vocal-instructor-zachary-gordin-performs-hahns-favorite-pieces.html",
            "image_url": "http://www.sonoma.edu/newscenter/assets_c/2017/04/gordin-thumb-150x198-13065.jpg",
            "summary": "Sonoma State University vocal instructor and acclaimed baritone Zachary Gordin will perform with pianist Bryan Nies to present for an intimate recital of vocal music highlighting the works of Venezuelan-French composer Reynaldo Hahn at 7:30 p.m. on April 27 in...",
            "author": "Ali Kooshesh",
            "category": "Arts and Lectures",
            "content": "<p>Fake article content</p>\n"
        ]
        let article = self.article!
        article.initializeWith(json: JSON(dict))
        
        expect(article.id) == "tag:www.sonoma.edu,2017:/newscenter//77.30937"
        expect(article.published?.iso8601String) == "2017-04-14T18:02:32Z"
        expect(article.title) == "Vocal Instructor Zachary Gordin Performs Hahn's Favorite Pieces"
        expect(article.link) == "http://www.sonoma.edu/newscenter/2017/04/vocal-instructor-zachary-gordin-performs-hahns-favorite-pieces.html"
        expect(article.imageURL) == "http://www.sonoma.edu/newscenter/assets_c/2017/04/gordin-thumb-150x198-13065.jpg"
        expect(article.summary) == "Sonoma State University vocal instructor and acclaimed baritone Zachary Gordin will perform with pianist Bryan Nies to present for an intimate recital of vocal music highlighting the works of Venezuelan-French composer Reynaldo Hahn at 7:30 p.m. on April 27 in..."
        expect(article.author) == "Ali Kooshesh"
        expect(article.category) == "Arts and Lectures"
        expect(article.content) == "<p>Fake article content</p>\n"
    }
}
