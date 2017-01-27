
//  MovieFetcher.h
//  Flicks
//
//  Created by Shruthi Ramesh on 1/12/17.
//  Copyright © 2017 Flurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

typedef void (^MovieListFetcherCallback)(NSArray *movies, NSError* error);
typedef void (^MovieImageFetcherCallback)(UIImage *image, NSError* error);
typedef void (^MovieFetcherCallback)(NSDictionary *movie, NSError* error);

@interface MovieFetcher : NSObject
+ (id)sharedInstance ;
-(void) fetchTopRated:(MovieListFetcherCallback)callback;
-(void) fetchNowPlaying:(MovieListFetcherCallback)callback;
-(void) fetchMovieDetails:(MovieFetcherCallback)callback movieId:(NSString*) movieId;
-(void) fetchImageForURL:(NSURL*)url withCallback:(MovieImageFetcherCallback)callback;
@end
