//
//  MovieModel.h
//  Flicks
//
//  Created by  Steve Carlson (Media Engineering) on 1/23/17.
//  Copyright © 2017 Steve Carlson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *movieDescription;
@property (nonatomic, strong) NSURL *posterUrl;

@end
