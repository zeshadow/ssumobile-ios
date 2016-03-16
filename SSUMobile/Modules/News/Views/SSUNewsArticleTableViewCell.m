//
//  SSUNewsArticleTableViewCell.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNewsArticleTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SSUNewsConstants.h"

@interface SSUNewsArticleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation SSUNewsArticleTableViewCell

- (void)setArticle:(SSUArticle *)article {
    if (article == _article && (_article.imageURL == nil ||
                                [_article.imageURL isEqualToString:@""])) {
        return;
    }
    _article = article;
    
    static NSDateFormatter * dateFormmater = nil;
    if (dateFormmater == nil) {
        dateFormmater = [NSDateFormatter new];
        dateFormmater.dateStyle = NSDateFormatterShortStyle;
        dateFormmater.timeStyle = NSDateFormatterNoStyle;
    }
    
    self.titleLabel.text = article.title;
    self.summaryLabel.text = article.summary;
    self.dateLabel.text = [dateFormmater stringFromDate:article.published];
    self.image.image = nil; // Clear out the existing image since we reuse cells
    [self.image sd_setImageWithURL:[NSURL URLWithString:article.imageURL]];
}


@end
