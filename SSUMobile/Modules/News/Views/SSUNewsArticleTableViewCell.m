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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation SSUNewsArticleTableViewCell

- (void)setArticle:(SSUArticle *)article {
    if (article == _article && (_article.imageURL == nil ||
                                [_article.imageURL isEqualToString:@""])) {
        return;
    }
    _article = article;
    
    static CGFloat originalImageContainerWidthConstraintConstant = 0;
    static CGRect originalImageViewFrame;
    if (originalImageContainerWidthConstraintConstant == 0) {
        originalImageContainerWidthConstraintConstant = self.imageContainerWidthConstraint.constant;
        originalImageViewFrame = self.imageView.frame;
    }
    
    self.titleLabel.text = article.title;
    self.summaryLabel.text = article.summary;
    self.image.image = nil; // Clear out the existing image since we reuse cells
    self.imageContainerWidthConstraint.constant = !article.imageURL ? 0 : originalImageContainerWidthConstraintConstant;
    [self.image sd_setImageWithURL:[NSURL URLWithString:article.imageURL]];
}


@end
