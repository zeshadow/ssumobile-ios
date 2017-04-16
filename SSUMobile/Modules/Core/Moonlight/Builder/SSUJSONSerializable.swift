//
//  SSUJSONSerializable.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/16/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import SwiftyJSON


@objc
protocol SSUJSONInitializable: class {
    /**
     Initialize the object's properties with the provided JSON dictionary
     
     - note: If a key is missing or nil, then the resulting property on this object should also be set to nil
     */
    func initializeWith(dict: [AnyHashable:Any])
}

// The SwiftyJSON.JSON struct is not available in objc, so provide default implementations using extensions

extension SSUJSONInitializable {
    func initializeWith(json: JSON) {
        initializeWith(dict: json.dictionaryObject ?? [:])
    }
}



@objc
protocol SSUJSONSerializable: class {
    /**
     Update the object's properties with the provided JSON dictionary.
     
     - note:    Do not assume that all the possible properties are present. This functions as a "partial update",
     so any properties not present in the provided dictionary should be left untouched
     */
    func updateWith(dict: [AnyHashable:Any])
}


extension SSUJSONSerializable {
    func updateWith(json: JSON){
        updateWith(dict: json.dictionaryObject ?? [:])
    }
}
