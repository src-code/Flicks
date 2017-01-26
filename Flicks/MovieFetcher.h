
//  MovieFetcher.h
//  Flicks
//
//  Created by Shruthi Ramesh on 1/12/17.
//  Copyright © 2017 Flurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

typedef void (^MovieFetcherCallback)(NSArray *movies, NSError* error);
typedef void (^MovieImageFetcherCallback)(UIImage *image, NSError* error);
typedef void (^MovieDetailsFetcherCallback)(NSDictionary *movie, NSError* error);

@interface MovieFetcher : NSObject
+ (id)sharedInstance ;
-(void) fetchTopRated:(MovieFetcherCallback)callback;
-(void) fetchNowPlaying:(MovieFetcherCallback)callback;
-(void) fetchMovieDetails:(MovieDetailsFetcherCallback)callback movieId:(NSString*) movieId;
-(void) fetchImageForURL:(NSURL*)url withCallback:(MovieImageFetcherCallback)callback;
@end
