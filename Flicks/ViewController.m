//
//  ViewController.m
//  Flicks
//
//  Created by  Steve Carlson (Media Engineering) on 1/23/17.
//  Copyright © 2017 Steve Carlson. All rights reserved.
//

#import "ViewController.h"
#import "MovieCell.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "MovieDetailViewController.h"
#import "MovieFetcher.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MoviePosterCollectionViewCell.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewModeSelector;
@property (strong, nonatomic) UICollectionView *movieCollectionView;
@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (weak, nonatomic) MovieFetcher *movieFetcher;
@property (weak, nonatomic) IBOutlet UIView *errorBar;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Flicks";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.movieFetcher = [MovieFetcher sharedInstance];
    
    // Table View
    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;
    
    // Collection View
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat itemHeight = 150; // FIXME: Unfix this value so the aspect ratio is correct
    CGFloat itemWidth = screenWidth / 3;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 64) collectionViewLayout:layout];
    [collectionView registerClass:[MoviePosterCollectionViewCell class] forCellWithReuseIdentifier:@"MoviePosterCollectionViewCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    self.movieCollectionView = collectionView;

    // Pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    // Set the view mode
    [self setViewMode];
    
    // Fetch the movie data
    [self fetchMovies];
}

- (void)fetchMovies {
    MovieListFetcherCallback callback = ^(NSArray *movies, NSError* error) {
        if (!error) {
            self.movies = movies;
            [self.movieTableView reloadData];
            [self.movieCollectionView reloadData];
        } else {
            self.errorText.text = @"Network error";
            self.errorBar.hidden = NO;
            NSLog(@"An error occurred: %@", error.description);
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshControl endRefreshing];
    };
    
    self.errorBar.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([self.restorationIdentifier isEqualToString:@"now_playing"]) {
        [self.movieFetcher fetchNowPlaying:callback];
    } else {
        [self.movieFetcher fetchTopRated:callback];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.movieTableView.frame = self.view.bounds;
    self.movieCollectionView.frame = self.view.bounds;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *selectedIndex;
    if (self.viewModeSelector.selectedSegmentIndex == 0) {
        selectedIndex = [self.movieTableView indexPathForSelectedRow];
    } else {
        selectedIndex = [self.movieCollectionView indexPathForCell:sender];
    }
    
    MovieDetailViewController *segueViewController = [segue destinationViewController];
    MovieModel *movieModel = [self.movies objectAtIndex:selectedIndex.row];
    segueViewController.movieId = movieModel.id;
}

- (void)setViewMode {
    if (self.viewModeSelector.selectedSegmentIndex == 0) {
        // List mode
        self.movieCollectionView.hidden = YES;
        self.movieTableView.hidden = NO;
        [self.movieTableView insertSubview:self.refreshControl atIndex:0];
    } else {
        // Grid mode
        self.movieCollectionView.hidden = NO;
        self.movieTableView.hidden = YES;
        [self.movieCollectionView insertSubview:self.refreshControl atIndex:0];
    }
}

- (IBAction)onViewModeChange:(UISegmentedControl *)sender {
    [self setViewMode];
}

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.movieTableView deselectRowAtIndexPath:indexPath animated:true];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = model.title;
    cell.overviewLabel.text = model.movieDescription;
    cell.posterImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.posterImage setImageWithURL:model.posterUrl];

    return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MoviePosterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviePosterCollectionViewCell" forIndexPath:indexPath];
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"detail_view" sender:cell];
}
@end
