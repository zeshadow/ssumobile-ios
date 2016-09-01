@import Foundation;
@import CoreData;
#import "SSUNewsObject.h"


@interface SSUArticle : SSUNewsObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;

@end
