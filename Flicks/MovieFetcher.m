//
//  MovieFetcher.m
//  Flicks
//
//  Created by Shruthi Ramesh on 1/12/17.
//  Copyright © 2017 Flurry. All rights reserved.
//

#import "MovieFetcher.h"
#import "MovieModel.h"

@implementation MovieFetcher

NSString *apiKey = @"f5408bb6365a69cb9fb8fadf33040c7a";

+ (id)sharedInstance {
    static MovieFetcher *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    return mgr;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void) fetchTopRated:(MovieListFetcherCallback)callback
{
    NSString *urlString =
    [@"https://api.themoviedb.org/3/movie/top_rated?api_key=" stringByAppendingString:apiKey];
    MovieFetcherCallback cb = ^(NSDictionary *dictionary, NSError *error) {
        NSArray* movies = [self parseResponse:dictionary];
        callback(movies, error);
    };
    [self fetchWithURL:urlString callback:cb];
}
-(void) fetchNowPlaying:(MovieListFetcherCallback)callback
{
    NSString *urlString =
    [@"https://api.themoviedb.org/3/movie/now_playing?api_key=" stringByAppendingString:apiKey];
    MovieFetcherCallback cb = ^(NSDictionary *dictionary, NSError *error) {
        NSArray* movies = [self parseResponse:dictionary];
        callback(movies, error);
    };
    [self fetchWithURL:urlString callback:cb];
}

-(void) fetchMovieDetails:(MovieFetcherCallback)callback movieId:(NSString*)movieId
{
    NSString *urlString =
    [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@&append_to_response=videos", movieId, apiKey];
    [self fetchWithURL:urlString callback:callback];
}

-(void) fetchWithURL:(NSString*)urlString callback:(MovieFetcherCallback)callback
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    //NSLog(@"Response: %@", responseDictionary);
                                                    callback(responseDictionary,jsonError);
                                                } else {
                                                    callback(nil,error);
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
    
}

-(void) fetchImageForURL:(NSURL*)url withCallback:(MovieImageFetcherCallback)callback;
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    callback([UIImage imageWithData:data] , error);
                                                } else {
                                                    callback(nil,error);
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
    
}


-(NSArray*)parseResponse:(NSDictionary*)responseDictionary
{
    NSMutableArray* movieArray = [NSMutableArray new];
    NSArray* results = [responseDictionary objectForKey:@"results"];
    for (NSDictionary* dict in results) {
        [movieArray addObject:[[MovieModel alloc] initWithDictionary:dict]];
    }
    return movieArray;
}


@end
