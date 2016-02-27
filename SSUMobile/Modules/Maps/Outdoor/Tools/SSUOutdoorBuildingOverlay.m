//
//  SSUBuildingOverlay.m
//  SSUMobile
//
//  Created by Andrew Huss on 2/18/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorBuildingOverlay.h"

@interface SSUOutdoorBuildingOverlay(){}

@property (strong, nonatomic) UILabel* nameLabel;

@end

@implementation SSUOutdoorBuildingOverlay

- (void) setBuilding:(SSUBuilding *)building {
    _building = building;
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = self.bounds;
        _nameLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    _nameLabel.text = _building.name;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    UIGraphicsPushContext(context);
    [_nameLabel drawTextInRect:_nameLabel.frame];
    UIGraphicsPopContext();
}

@end
