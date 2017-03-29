//
//  SSUNewsArticleTableViewCell.swift
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

import Foundation

class SSUNewsArticleTableViewCell: UITableViewCell {
    
    var article: SSUArticle? {
        didSet {
            updateDisplay()
        }
    }
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    
    let titleLabel = UILabel()
    let summaryLabel = UILabel()
    let dateLabel = UILabel()
    let articleImageView = UIImageView()
    
    private let separatorLineHeight: CGFloat = 2.0
    
    private var hasImage: Bool {
        return articleImageView.image != nil
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
        contentView.addSubview(summaryLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(articleImageView)
        
        let padding = 8.0
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .darkText
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(padding)
            make.left.equalToSuperview().inset(padding)
            make.right.equalToSuperview().inset(padding)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = .ssuBlue
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(separatorLineHeight)
            make.top.equalTo(titleLabel.snp.bottom).offset(padding/2.0)
        }
        
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(padding/2.0)
            make.top.equalTo(lineView.snp.bottom).offset(padding)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalTo(articleImageView.snp.width)
        }
        
        dateLabel.font = UIFont.systemFont(ofSize: 9.0, weight: UIFontWeightLight)
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(articleImageView)
            make.top.equalTo(articleImageView.snp.bottom).offset(padding/4.0)
            make.bottom.lessThanOrEqualToSuperview().inset(padding/4.0)
        }
        
        summaryLabel.font = UIFont.systemFont(ofSize: 12.0)
        summaryLabel.numberOfLines = 0
        summaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(articleImageView.snp.top)
            make.left.equalToSuperview().inset(padding)
            make.right.equalTo(articleImageView.snp.left).offset(-padding/2.0)
            make.bottom.lessThanOrEqualTo(dateLabel)
        }
 
        isAccessibilityElement = false
        accessibilityElements = [titleLabel, dateLabel, summaryLabel]
        accessibilityHint = NSLocalizedString("Read full article", comment: "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        article = nil
    }
    
    private func updateDisplay() {
        titleLabel.text = article?.title
        summaryLabel.text = article?.summary
        if let date = article?.published {
            dateLabel.text = SSUNewsArticleTableViewCell.dateFormatter.string(from: date as Date)
        } else {
            dateLabel.text = nil
        }
        articleImageView.image = nil
        if let imageURLString = article?.imageURL, !imageURLString.isEmpty {
            let url = URL(string: imageURLString)
            articleImageView.kf.indicatorType = .activity
            articleImageView.kf.setImage(with: url, completionHandler: { (image, error, cacheType, imageURL) in
                self.articleImageView.isHidden = image == nil
            })
        }
    }
}
