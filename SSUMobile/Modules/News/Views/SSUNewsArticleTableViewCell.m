//
//  SSUNewsArticleTableViewCell.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNewsArticleTableViewCell.h"
#import "SSUNewsConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

static const CGFloat separatorHeight = 2.0;

@interface SSUNewsArticleTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *articleImageView;

@end

@implementation SSUNewsArticleTableViewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self initialize];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initialize];
    return self;
}

- (void) initialize {
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.titleLabel.textColor = [UIColor darkTextColor];
    self.titleLabel.numberOfLines = 2;
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
        make.left.equalTo(self.contentView.mas_left).offset(8.0);
        make.right.equalTo(self.contentView.mas_right).offset(-8.0);
    }];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    
    UIView * lineView = [UIView new];
    lineView.backgroundColor = SSU_BLUE_COLOR;
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(separatorHeight);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4.0);
    }];
    
    self.articleImageView = [UIImageView new];
    self.articleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.articleImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.articleImageView];
    [self.articleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-4.0);
        make.top.equalTo(lineView.mas_bottom).offset(4.0);
        make.width.equalTo(self.contentView.mas_width).multipliedBy(0.25);
        make.height.equalTo(self.articleImageView.mas_width);
    }];
    
    self.dateLabel = [UILabel new];
    [self.contentView addSubview:self.dateLabel];
    self.dateLabel.font = [UIFont systemFontOfSize:9.0 weight:UIFontWeightLight];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.articleImageView.mas_right);
        make.top.equalTo(self.articleImageView.mas_bottom).offset(4.0);
        make.left.greaterThanOrEqualTo(self.contentView.mas_left);
    }];
    
    self.summaryLabel = [UILabel new];
    self.summaryLabel.font = [UIFont systemFontOfSize:12.0];
    self.summaryLabel.numberOfLines = 0;
    [self.contentView addSubview:self.summaryLabel];
    [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.articleImageView.mas_top);
        make.left.equalTo(self.contentView.mas_left).offset(8.0);
        make.right.equalTo(self.articleImageView.mas_left).offset(-4.0);
        make.bottom.equalTo(self.dateLabel.mas_bottom);
    }];
}

- (void)setArticle:(SSUArticle *)article {
    _article = article;
    
    static NSDateFormatter * dateFormmater = nil;
    if (dateFormmater == nil) {
        dateFormmater = [NSDateFormatter new];
        dateFormmater.dateStyle = NSDateFormatterShortStyle;
        dateFormmater.timeStyle = NSDateFormatterShortStyle;
    }
    
    self.titleLabel.text = article.title;
    self.summaryLabel.text = article.summary;
    self.dateLabel.text = [dateFormmater stringFromDate:article.published];
    self.articleImageView.image = nil; // Clear out the existing image since we reuse cells
    if (_article.imageURL != nil && ![_article.imageURL isEqualToString:@""]) {
        [self.articleImageView sd_setImageWithURL:[NSURL URLWithString:article.imageURL]];
    }
}


@end
