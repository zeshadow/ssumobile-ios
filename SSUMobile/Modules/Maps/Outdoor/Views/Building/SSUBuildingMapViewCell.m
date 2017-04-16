//
//  SSUBuildingMapViewCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 10/15/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUBuildingMapViewCell.h"
#import "SSUMapModels.h"
#import "SSUMapBuilder.h"
#import "SSUMobile-Swift.h"

enum {
    PageControlIndexMapView,
    PageControlIndexImageView,
};

@interface SSUBuildingMapViewCell()

@property (nonatomic) IBOutlet UIView * overlayView;
@property (nonatomic) IBOutlet UIPageControl * pageControl;
@property (nonatomic) SSUMapBuildingPerimeter * perimeter;

@end

@implementation SSUBuildingMapViewCell

- (void) awakeFromNib {
    [super awakeFromNib];
    /**
     For now, this will be unused. Adding building images will hopefully be done
     in the next release.
     The page control has been disabled and hidden in the storyboard. Once the images are set up
     the relevant views must be enabled
     */
    //NSString * url = @"https://moonlight.cs.sonoma.edu/ssumobile/1_0/images/art_building.jpg";
    //[self.buildingImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    //[self pageControlChangedPage:self.pageControl];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) setShowsOverlay:(BOOL)showsOverlay {
    _showsOverlay = showsOverlay;
    self.overlayView.hidden = !showsOverlay;
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:NO];
}

- (void) setBuilding:(SSUBuilding *)building {
    _building = building;
    self.perimeter = [SSUMapBuilder perimeterForBuilding:_building inContext:[SSUMapModule sharedInstance].context];
    [self.mapView addOverlay:self.perimeter.polygon];
    [self moveMapViewToBuilding];
    
    self.buildingLabel.text = self.building.displayName;
}

- (IBAction)pageControlChangedPage:(UIPageControl *)control {
    self.imageView.hidden = control.currentPage != PageControlIndexImageView;
    self.mapView.hidden = control.currentPage != PageControlIndexMapView;
}

- (void) moveMapViewToBuilding {
    MKMapRect rect = self.perimeter.boundingMapRect;
    rect = MKMapRectInset(rect, -rect.size.width, -rect.size.height);
    [self.mapView setVisibleMapRect:rect animated:NO];
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        renderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        renderer.lineWidth = 1;
        return renderer;
    }
    return nil;
}

@end
