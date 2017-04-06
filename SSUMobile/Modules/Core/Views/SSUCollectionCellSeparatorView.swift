//
//  SSUCollectionCellSeparatorView.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/4/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import UIKit

class SSUCollectionCellSeparatorView: UIView {
    
    var separator: SSUCellSeparator = [] {
        didSet {
            setNeedsLayout()
        }
    }
    var separatorColor: UIColor = .ssuBlue {
        didSet {
            setNeedsLayout()
        }
    }
    
    var separatorLineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let separatorLayer = CAShapeLayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layer.addSublayer(separatorLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resetSeparator()
    }
    
    private func resetSeparator() {
        separatorLayer.strokeColor = separatorColor.cgColor
        separatorLayer.lineWidth = separatorLineWidth
        
        let path = UIBezierPath()
        
        if separator.contains(.top) {
            let start = bounds.origin
            let end = CGPoint(x: bounds.maxX, y: bounds.minY)
            path.move(to: start)
            path.addLine(to: end)
        }
        if separator.contains(.right) {
            let start = bounds.topRight
            let end = bounds.bottomRight
            path.move(to: start)
            path.addLine(to: end)
        }
        if separator.contains(.bottom) {
            let start = bounds.bottomLeft
            let end = bounds.bottomRight
            path.move(to: start)
            path.addLine(to: end)
        }
        if separator.contains(.left) {
            let start = bounds.topLeft
            let end = bounds.bottomLeft
            path.move(to: start)
            path.addLine(to: end)
        }
        
        separatorLayer.path = path.cgPath
    }
}
