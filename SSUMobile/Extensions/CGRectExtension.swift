//
//  CGRectExtension.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/4/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {

    var topLeft: CGPoint {
        return CGPoint(x: minX, y: minY)
    }
    
    var topRight: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    
    var bottomRight: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
    
    var bottomLeft: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }
}
