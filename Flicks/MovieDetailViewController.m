//
//  MovieDetailViewController.m
//  Flicks
//
//  Created by  Steve Carlson (Media Engineering) on 1/24/17.
//  Copyright © 2017 Steve Carlson. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "MovieFetcher.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *MovieDetailScrollView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDate;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) MovieFetcher *movieFetcher;
@property (weak, nonatomic) NSDictionary *movie;
@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardView.hidden = true;
    self.movieFetcher = [MovieFetcher sharedInstance];

    // NSLog(@"movie id %@", self.movieId);

    MovieFetcherCallback callback = ^(NSDictionary *movie, NSError* error) {
        if (!error) {
            NSLog(@"movie data fetched for movie id %@: %@", self.movieId, movie);
            self.movie = movie;

            // Background Url
            NSString *backdropUrlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", movie[@"backdrop_path"]];
            NSURL *backdropUrl = [NSURL URLWithString:backdropUrlString];

            // Release Date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *releaseDate = [dateFormatter dateFromString:movie[@"release_date"]];
            [dateFormatter setDateFormat:@"MMMM d, y"];
            NSString *releaseDateString = [dateFormatter stringFromDate:releaseDate];
            NSLog(@"release date %@", releaseDateString);
            
            // Set UI values
            self.titleLabel.text = movie[@"title"];
            self.descriptionLabel.text = movie[@"overview"];
            self.releaseDate.text = releaseDateString;
            float rating = [[movie objectForKey:@"vote_average"] floatValue];
            self.ratingLabel.text = [NSString stringWithFormat:@"%.01f / 10", rating];
            self.durationLabel.text = [NSString stringWithFormat:@"%@ minutes", movie[@"runtime"]];
            [self.posterImage setImageWithURL:backdropUrl];
            
            self.MovieDetailScrollView.contentInset = UIEdgeInsetsMake(180, 0, 0, 0);
            CGFloat contentOffsetY = 0 + CGRectGetHeight(self.cardView.bounds);
            self.MovieDetailScrollView.contentSize = CGSizeMake(self.MovieDetailScrollView.bounds.size.width, contentOffsetY);
            
            self.cardView.hidden = false;
        } else {
            NSLog(@"An error occurred when fetching movie details: %@", error.description);
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.movieFetcher fetchMovieDetails:callback movieId:self.movieId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    NSLog(@"segue MovieDetailViewController %@", sender);
//    
//}

@end
