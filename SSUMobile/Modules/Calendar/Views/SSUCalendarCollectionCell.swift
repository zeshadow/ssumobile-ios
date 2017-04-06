//
//  SSUCalendarCollectionCell.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/5/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

class SSUCalendarCollectionCell: FSCalendarCell {
    
    private let separatorView = SSUCollectionCellSeparatorView()
    private let eventCountLabel = UILabel()
    
    var separator: SSUCellSeparator {
        set {
            separatorView.separator = newValue
        } get {
            return separatorView.separator
        }
    }
    
    var eventCount: Int = 0 {
        didSet {
            if eventCount > 0 {
                eventCountLabel.text = "\(eventCount)"
            } else {
                eventCountLabel.text = nil
            }
        }
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        contentView.addSubview(separatorView)
        contentView.addSubview(eventCountLabel)
        separatorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let padding = 2.0
        
        eventCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(padding)
            make.right.equalToSuperview().inset(padding)
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        eventCountLabel.font = calendar.appearance.subtitleFont
    }
}
