//
//  SSUCalendarEventCell.swift
//  SSUMobile
//
//  Created by Eric Amorde on 4/1/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SSUCalendarEventCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    var event: SSUEvent? {
        didSet {
            updateDisplay()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.textColor = UIColor.ssuBlue
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.leftMargin.equalToSuperview()
            make.rightMargin.equalToSuperview()
        }
        
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(8.0)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        event = nil
    }
    
    private func updateDisplay() {
        titleLabel.text = event?.title
        
        subtitleLabel.text = nil
        if let startDate = event?.startDate {
            let startTime = DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .short)
            if let location = event?.location?.trimmingCharacters(in: .whitespacesAndNewlines) {
                subtitleLabel.text = "\(startTime) - \(location)"
            } else {
                subtitleLabel.text = startTime
            }
        }
    }
}
