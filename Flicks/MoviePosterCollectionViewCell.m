//
//  MoviePosterCollectionViewCell.m
//  Flicks
//
//  Created by  Steve Carlson (Media Engineering) on 1/26/17.
//  Copyright © 2017 Steve Carlson. All rights reserved.
//

#import "MoviePosterCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MoviePosterCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MoviePosterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Weak reference until added as subview, thus 'strong' used in @property above to avoid memory reclaimation
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)reloadData {
    [self.imageView setImageWithURL:self.model.posterUrl];
    // Makes sure 'layoutSubviews()' is called
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Image view is same size as cell
    self.imageView.frame = self.contentView.bounds;
}

- (void)setModel:(MovieModel *)model {
    _model = model;
    [self reloadData];
}

@end
